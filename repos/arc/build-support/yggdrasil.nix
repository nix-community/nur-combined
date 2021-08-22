{ self, super, lib, ... }: with lib; let
  addPassthru = drv: {
    address = readFile "${drv}";
  };
  packages = {
    yggdrasil-address = { stdenvNoCC, yggdrasil }: pubkey: let
      drv = stdenvNoCC.mkDerivation {
        name = "yggdrasil-address-${pubkey}";

        nativeBuildInputs = [ yggdrasil ];

        yggdrasilConf = builtins.toJSON {
          EncryptionPublicKey = pubkey;
        };

        passAsFile = [ "yggdrasilConf" ];

        buildCommand = ''
          yggdrasil -useconffile $yggdrasilConfPath -address | tr -d '\n' > $out
        '';
      };
    in drvPassthru addPassthru drv;
  };
in mapAttrs (_: p: self.callPackage p { }) packages
