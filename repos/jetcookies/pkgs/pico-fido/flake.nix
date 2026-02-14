{
  description = "pico-fido matrix build flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
        allSupportedBoards = lib.filter
          (s: s != "" && !(lib.hasPrefix "#" s))
          (lib.splitString "\n" (lib.trim (builtins.readFile ./allSupportedBoards.txt)));
        argMatrix = lib.cartesianProduct {
          picoBoard = allSupportedBoards;
          vidpid = [ "NitroHSM" "NitroFIDO2" "NitroStart" "NitroPro" "Nitro3" "Yubikey5" "YubikeyNeo" "YubiHSM" "Gnuk" "GnuPG" null ];
        };
        allFirmwareDrvs = map (args: pkgs.callPackage ./default.nix { inherit (args) picoBoard vidpid; }) argMatrix;      
      in
      {
        packages.default = pkgs.symlinkJoin {
          name = "all-pico-fido-firmwares";
          paths = allFirmwareDrvs;
        };
      }
    );
}