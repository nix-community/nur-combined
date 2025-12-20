{
  lib,
  utils,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrsToList
    concatStringsSep
    foldl'
    getExe'
    last
    listToAttrs
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optional
    optionals
    singleton
    sortOn
    types
    ;
  cfg = config.security.systemIdentity;
  sdcfg = config.boot.initrd.systemd;
in
{
  options = {
    security.systemIdentity = {
      enable = mkEnableOption "hashing of Luks values into PCR 15 and subsequent checks";
      pcr15 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The expected value of PCR 15 after all luks partitions have been unlocked
          Should be a 64 character hex string as ouput by the sha256 field of
          'systemd-analyze pcrs 15 --json=short'
          If set to null (the default) it will not check the value.
          If the check fails the boot will abort and you will be dropped into an emergency shell, if enabled.
          In ermergency shell type:
          'systemctl disable check-pcrs'
          'systemctl default'
          to continue booting
        '';
        example = "6214de8c3d861c4b451acc8c4e24294c95d55bcec516bbf15c077ca3bffb6547";
      };
    };
    boot.initrd.luks.devices = mkOption {
      type =
        with types;
        attrsOf (submodule {
          config.crypttabExtraOpts = optionals cfg.enable [
            "tpm2-device=auto"
            "tpm2-measure-pcr=yes"
          ];
        });
    };
  };
  config = mkIf cfg.enable {
    boot.kernelParams = [
      "rd.luks=no"
    ];
    boot.initrd.systemd.extraBin = {
      jq = lib.getExe pkgs.jq;
    };
    # boot.initrd.systemd.storePaths = [ (getExe pkgs.jq) ];
    boot.initrd.systemd.services = {
      check-pcrs = mkIf (cfg.pcr15 != null) {
        script = ''
          echo "Checking PCR 15 value"
          if [[ $(systemd-analyze pcrs 15 --json=short | jq -r ".[0].sha256") != "${cfg.pcr15}" ]] ; then
            echo "PCR 15 check failed"
            exit 1
          else
            echo "PCR 15 check suceed"
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        unitConfig.DefaultDependencies = "no";
        after = [ "cryptsetup.target" ];
        before = [ "sysroot.mount" ];
        requiredBy = [ "sysroot.mount" ];
      };
    }
    // (
      sortOn (x: x.name) (attrsToList config.boot.initrd.luks.devices)
      |> foldl' (
        acc: device:
        acc
        ++ singleton (
          nameValuePair "cryptsetup-${device.name}" {
            unitConfig = {
              Description = "Cryptography setup for ${device.name}";
              DefaultDependencies = "no";
              IgnoreOnIsolate = true;
              Conflicts = [ "umount.target" ];
              BindsTo = "${utils.escapeSystemdPath device.value.device}.device";
            };
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              TimeoutSec = "infinity";
              KeyringMode = "shared";
              OOMScoreAdjust = 500;
              ImportCredential = "cryptsetup.*";
              ExecStart = ''${getExe' sdcfg.package "systemd-cryptsetup"} attach '${device.name}' '${device.value.device}' '-' '${
                device.value.crypttabExtraOpts ++ (optional device.value.allowDiscards "discard")
                |> concatStringsSep ","
              }' '';
              ExecStop = ''${getExe' sdcfg.package "systemd-cryptsetup"} detach '${device.name}' '';
            };
            after = [
              "cryptsetup-pre.target"
              "systemd-udevd-kernel.socket"
              "${utils.escapeSystemdPath device.value.device}.device"
            ]
            ++ (optional sdcfg.tpm2.enable "systemd-tpm2-setup-early.service")
            ++ optional (acc != [ ]) "${(last acc).name}.service";
            before = [
              "blockdev@dev-mapper-${device.name}.target"
              "cryptsetup.target"
              "umount.target"
            ];
            wants = [ "blockdev@dev-mapper-${device.name}.target" ];
            requiredBy = [ "sysroot.mount" ];
          }
        )
      ) [ ]
      |> listToAttrs
    );
  };
}
