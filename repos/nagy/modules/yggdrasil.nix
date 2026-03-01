{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.yggdrasil;
  readYggdrasilOutput =
    assert lib.assertMsg (
      !cfg.enable || !(cfg.settings ? PrivateKeyPath)
    ) "Yggdrasil service is not enabled and/or no PrivateKeyPath is set.";
    name:
    lib.readFile (
      pkgs.runCommandLocal "yggdrasil-output-${name}.txt"
        {
          nativeBuildInputs = [ cfg.package ];
          configfile = lib.toJSON cfg.settings;
          passAsFile = [ "configfile" ];
        }
        ''
          yggdrasil -useconffile "$configfilePath" -${name}|tr -d $'\n' > $out
        ''
    );
in
{
  options = {
    nagy.yggdrasil.addressOutput = lib.mkOption {
      type = lib.nullOr lib.str;
      default = readYggdrasilOutput "address";
      readOnly = true;
    };
    nagy.yggdrasil.subnetOutput = lib.mkOption {
      type = lib.nullOr lib.str;
      default = readYggdrasilOutput "subnet";
      readOnly = true;
    };
    nagy.yggdrasil.publickeyOutput = lib.mkOption {
      type = lib.nullOr lib.str;
      default = readYggdrasilOutput "publickey";
      readOnly = true;
    };
  };

  config = {
    services.yggdrasil = {
      enable = lib.mkDefault true;
      group = "wheel";
      package = lib.mkDefault (
        pkgs.yggdrasil.overrideAttrs {
          src = pkgs.fetchurl {
            url = "https://github.com/nagy/yggdrasil-go/archive/59f9fc42625cebe1f0a61772aff5a5219901c9d1.tar.gz";
            hash = "sha256-B/UsBQbvm8Lw85QBPiFfLkEH24DJJMtRFCGdKCCveAM=";
          };
          vendorHash = "sha256-6zakE/TTRN0ydf6rtJXPxN3hi8vKDlV6MVU77H96sZo=";
        }
      );
      settings = {
        IfName = "ygg0";
        NodeInfo = { };
        NodeInfoPrivacy = true;
        Listen = [ "vsock://host:1234" ];
        Peers = lib.optionals (
          config.virtualisation ? qemu && config.virtualisation.qemu.guestAgent.enable == true
        ) [ "vsock://host:1234" ];
      };
    };
    systemd.services.yggdrasil = {
      postStart = ''
        sleep 1
        ${pkgs.iproute2}/bin/ip -6 address flush dev ${cfg.settings.IfName} scope link
      '';
    };

    # to include AF_VSOCK
    systemd.services.yggdrasil.serviceConfig.RestrictAddressFamilies =
      lib.mkForce "AF_UNIX AF_INET AF_INET6 AF_NETLINK AF_VSOCK";

    networking.hosts = {
      "222:3bd:cc26:9545:caaa:9fd6:ec56:cc1" = [
        "y.www.nncpgo.org"
        "y.mirror.cypherpunks.su"
      ];
    };
  };
}
