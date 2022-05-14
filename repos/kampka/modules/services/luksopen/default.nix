{ config, pkgs, lib, ... }:

with lib;
let
  luksDevices = listToAttrs (
    map
      (device: {
        name = "${removePrefix "-" "${replaceStrings [ "/" ] [ "-" ] "${device.source}"}"}";
        value = device;
      })
      cfg.devices
  );

  cfg = config.kampka.services.luksopen;

  luksDeviceOpts = { name, ... }: {
    options = {
      source = mkOption {
        type = types.str;
        description = "The source device to be openeds";
      };

      target = mkOption {
        type = types.str;
        description = "The target device name";
      };

      keyFile = mkOption {
        type = types.path;
        description = "The key file used for decrytion.";
      };
    };
  };
in
{
  options.kampka.services.luksopen = {
    devices = mkOption {
      type = types.listOf (types.submodule luksDeviceOpts);
      description = "The list of luks devices to be opened.";
      example = [{ source = "/dev/sda"; target = "root"; }];
      default = [ ];
    };
  };

  config = mkIf (cfg.devices != [ ]) {
    systemd.services =
      let
      in
      flip mapAttrs' luksDevices (name: device: nameValuePair
        "luksopen-${name}"
        (
          let
            key-service = lists.optionals (strings.hasPrefix "/run/keys" device.keyFile) [ "${strings.replaceStrings [ "." ] [ "-" ] (lists.last (strings.splitString "/" device.keyFile)) }-key.service" ];
            device-service = [ "${removePrefix "-" "${replaceStrings [ "/" ] [ "-" ] (replaceStrings [ "-" ] [ "\\\\x2d" ] "${device.source}") }"}.device" ];
          in
          {
            after = [ "local-fs.target" ] ++ device-service ++ key-service;
            requires = device-service ++ key-service;
            wantedBy = [ "sysinit.target" ];
            script = ''
              set -e

              if [ -b "/dev/mapper/${device.target}" ]; then
                  if ! ${pkgs.cryptsetup}/bin/cryptsetup status "${device.target}" > /dev/null; then
                      echo "Target device name ${device.target} is already occupied and not a luks device."
                      exit 1
                  fi
                  echo "LUKS device already open. Skipping."
              else
                  ${pkgs.cryptsetup}/bin/cryptsetup --key-file ${device.keyFile} luksOpen "${device.source}" "${device.target}"
              fi
              ${pkgs.btrfs-progs}/bin/btrfs device scan
            '';

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          }
        ));
  };
}
