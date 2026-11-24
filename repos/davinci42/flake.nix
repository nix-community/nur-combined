{
  description = "Nix packages and NixOS/nix-darwin modules";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      modules = import ./default.nix { pkgs = null; };
      overlay = final: prev: {
        nur = prev.nur or { } // {
          davinci42 =
            removeAttrs (import ./default.nix { pkgs = final; }) [
              "nixosModules"
              "darwinModules"
            ]
            // prev.nur.davinci42 or { };
        };
      };
      wrapModules = lib.mapAttrs (
        _: module: {
          imports = [ module ];
          nixpkgs.overlays = [ overlay ];
        }
      );
    in
    {
      packages = lib.genAttrs systems (
        system:
        lib.filterAttrs (_: lib.meta.availableOn { inherit system; }) (
          removeAttrs (import ./default.nix { pkgs = nixpkgs.legacyPackages.${system}; }) [
            "nixosModules"
            "darwinModules"
          ]
        )
      );

      devShells = lib.genAttrs systems (system: {
        default = import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      });

      overlays.default = overlay;
      nixosModules = wrapModules modules.nixosModules;
      darwinModules = wrapModules modules.darwinModules;
    };
}
