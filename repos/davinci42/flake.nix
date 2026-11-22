{
  description = "Nix packages and NixOS/nix-darwin modules";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      modules = import ./default.nix { pkgs = null; };
      overlay = _: prev: {
        nur = prev.nur or { } // {
          davinci42 = self.packages.${prev.stdenv.hostPlatform.system} // prev.nur.davinci42 or { };
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
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nur = removeAttrs (import ./default.nix { inherit pkgs; }) [
            "nixosModules"
            "darwinModules"
          ];
        in
        lib.filterAttrs (_: lib.meta.availableOn { inherit system; }) (
          nur // import ./cached.nix { inherit pkgs; }
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
