{
  description = "pico-fido-firmwares matrix build flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
        perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          boards = lib.filter
            (s: s != "" && !(lib.hasPrefix "#" s))
            (lib.splitString "\n" (lib.trim (builtins.readFile ./boards.txt)));
          picofidoArgMatrix = lib.cartesianProduct {
            picoBoard = boards;
            enableEdDSA = [ true false ];
          };
          picofidoFirmwares = map (args: pkgs.callPackage ./default.nix { inherit (args) picoBoard enableEdDSA; }) picofidoArgMatrix;
        in
        {
          packages = {
            pico-fido-firmwares = pkgs.symlinkJoin {
              name = "pico-fido-firmwares";
              paths = picofidoFirmwares;
            };
          };
        };
      }
    );
}
