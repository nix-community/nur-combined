{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types) nullOr str;
  readYggdrasilOutput =
    if (config.services.yggdrasil.enable && config.services.yggdrasil.settings ? PrivateKey) then
      (
        name:
        builtins.readFile (
          pkgs.runCommandLocal "yggdrasil-output-${name}.txt" {
            nativeBuildInputs = [ config.services.yggdrasil.package ];
            configfile = builtins.toJSON config.services.yggdrasil.settings;
            passAsFile = [ "configfile" ];
          } ''yggdrasil -useconffile "$configfilePath" -${name}|tr -d $'\n'> $out''
        )
      )
    else
      _name: null;
in
{
  options = {
    nagy.yggdrasil.addressOutput = lib.mkOption {
      type = nullOr str;
      default = readYggdrasilOutput "address";
      readOnly = true;
    };
    nagy.yggdrasil.subnetOutput = lib.mkOption {
      type = nullOr str;
      default = readYggdrasilOutput "subnet";
      readOnly = true;
    };
    nagy.yggdrasil.publickeyOutput = lib.mkOption {
      type = nullOr str;
      default = readYggdrasilOutput "publickey";
      readOnly = true;
    };
  };

  config = lib.mkIf config.services.yggdrasil.enable {
    services.yggdrasil = {
      group = "wheel";
      package = pkgs.yggdrasil.overrideAttrs (old: {
        src = pkgs.fetchurl {
          url = "https://github.com/nagy/yggdrasil-go/archive/vsock.tar.gz";
          hash = "sha256-aym/WvnInF7o+0Ru96WYTpZm6IL0gW41XFW8C8KGk0s=";
        };
        vendorHash = "sha256-ZrciqrbH3/tD7yqT4+ZJJ0sloeHXI+wFn+aGEhgtQPI=";
        patches = [
          # shorter private keys
          (pkgs.fetchpatch {
            url = "https://github.com/nagy/yggdrasil-go/commit/a2f361eca7bb10ea198e25162c48892876763c23.patch";
            hash = "sha256-NbCFhlkIyNcXFt5FM86XjEtWJpagDwWSeq4skazhaj0=";
          })
        ];
      });
      settings = {
        IfName = "ygg0";
        NodeInfo = { };
        NodeInfoPrivacy = true;
      };
    };
    systemd.services.yggdrasil = {
      postStart = ''
        sleep 1
        ${pkgs.iproute2}/bin/ip -6 address flush dev ${config.services.yggdrasil.settings.IfName} scope link
      '';
    };

    networking.hosts = {
      "222:3bd:cc26:9545:caaa:9fd6:ec56:cc1" = [
        "y.www.nncpgo.org"
        "y.mirror.cypherpunks.su"
      ];
      "202:2892:ef61:1c65:4822:8893:4b6f:87bd" = [ "ipfs.ygg" ];
      "21e:a51c:885b:7db0:166e:927:98cd:d186" = [ "sites.ygg" ];
      "200:6223::d35b:1fd8:be0d:2841" = [ "myip.ygg" ];
      "324:71e:281a:9ed3::ace" = [ "acetone.ygg" ];
      "128.140.56.86" = [ "ygg.mkg20001.io" ];
      "5.75.213.206" = [ "ygg-uplink.thingylabs.io" ];
    };
  };
}
