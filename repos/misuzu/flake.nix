{
  outputs =
    inputs:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
      defaultNixosModules = {
        overlay = {
          nixpkgs.overlays = [ inputs.self.overlays.default ];
        };
      }
      // import ./nixos/default.nix;
    in
    {
      checks = forAllSystems (system: inputs.self.packages.${system});
      nixosModules = {
        default = {
          imports = builtins.attrValues defaultNixosModules;
        };
        cache = {
          nix.settings = {
            substituters = [
              "https://cache.ztier.in"
            ];
            trusted-public-keys = [
              "cache.ztier.link-1:3P5j2ZB9dNgFFFVkCQWT3mh0E+S3rIWtZvoql64UaXM="
            ];
          };
        };
      }
      // defaultNixosModules;
      overlays.default = import ./pkgs/overlay.nix;
      packages = forAllSystems (
        system:
        let
          sources = import ./nix/sources.nix;
          nixpkgs = import sources.nixpkgs { inherit system; };
        in
        import ./pkgs/default.nix { inherit (nixpkgs) pkgs; }
      );
    };
}
