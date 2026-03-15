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
      !cfg.enable || (config.nagy.yggdrasil.privatekeyEntropy != null)
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
  privateKeyFromEntropy =
    hashfile:
    pkgs.runCommandLocal "mykey.pem"
      {
        nativeBuildInputs = [ config.services.yggdrasil.package ];
      }
      ''
        hash=$(sha256sum < ${hashfile} | cut -d" " -f1 | tr -d $'\n')
        echo "{\"PrivateKey\":\"$hash\"}" | yggdrasil -useconf -exportkey > $out
      '';
in
{
  options = {
    nagy.yggdrasil.addressOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = readYggdrasilOutput "address";
      readOnly = true;
    };
    nagy.yggdrasil.subnetOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = readYggdrasilOutput "subnet";
      readOnly = true;
    };
    nagy.yggdrasil.publickeyOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = readYggdrasilOutput "publickey";
      readOnly = true;
    };
    nagy.yggdrasil.privatekeyEntropy = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    nagy.yggdrasil.connectToPublicPeers = lib.mkEnableOption ''
      yggdrasil should connect to some public peers in Europe
    '';
    nagy.yggdrasil.listenIpv4All = lib.mkEnableOption ''
      yggdrasil should listen on all ipv4 addresses
    '';
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
        Listen = [
          "vsock://host:1234"
        ]
        ++ (lib.optionals config.nagy.yggdrasil.listenIpv4All [
          "tcp://0.0.0.0:9001"
        ]);
        Peers =
          (lib.optionals config.nagy.yggdrasil.connectToPublicPeers [
            # Hetzner
            "tls://ygg1.mk16.de:1338"
            "tls://ygg.mkg20001.io:443"
          ])
          ++ (lib.optionals (
            config.virtualisation ? qemu && config.virtualisation.qemu.guestAgent.enable == true
          ) [ "vsock://host:1234" ]);
      }
      // (lib.optionalAttrs (config.nagy.yggdrasil.privatekeyEntropy != null) {
        PrivateKeyPath = privateKeyFromEntropy config.nagy.yggdrasil.privatekeyEntropy;
      });
    };
    systemd.services.yggdrasil = {
      postStart = ''
        sleep 1
        ${pkgs.iproute2}/bin/ip -6 address flush dev ${cfg.settings.IfName} scope link
      '';
    };

    networking.firewall = lib.mkIf config.nagy.yggdrasil.listenIpv4All {
      allowedTCPPorts = [ 9001 ];
    };

    environment.etc."yggdrasil-address.txt" =
      lib.mkIf (config.nagy.yggdrasil.privatekeyEntropy != null)
        {
          mode = "0444";
          text = ''
            ${config.nagy.yggdrasil.addressOutput}
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
