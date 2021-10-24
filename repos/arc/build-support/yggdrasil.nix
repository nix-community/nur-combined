{ self, super, lib, ... }: with lib; let
  addPassthru = drv: {
    import = removeSuffix "\n" (readFile "${drv}");
  };
  packages = {
    calculateYggdrasilAddress = { stdenvNoCC, yggdrasil-address }: pubkey: let
      drv = stdenvNoCC.mkDerivation {
        name = "yggdrasil-address-${pubkey}";

        nativeBuildInputs = singleton yggdrasil-address;

        inherit pubkey;
        buildCommand = ''
          yggdrasil-address "$pubkey" > $out
        '';
      };
    in drvPassthru addPassthru drv;
  };
in mapAttrs (_: p: self.callPackage p { }) packages
