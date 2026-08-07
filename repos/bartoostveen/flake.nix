{
  description = "Personal packages that are not in nixpkgs because they can't/won't be upstreamed";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:

      let
        inherit (lib)
          # keep-sorted start
          filterAttrs
          flip
          isDerivation
          mapAttrs
          # keep-sorted end
          ;
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        flake.overlays = {
          default =
            _: prev:
            import ./. {
              inherit (prev.stdenv.hostPlatform) system;
              pkgs = prev;
            };
          suppressSystemWarning = _: _: { _bartPackages.suppressSystemWarning = true; };
        };

        flake = {
          inherit inputs;

          hydraJobs =
            let
              filter =
                obj:
                if builtins.isFunction obj || obj ? __functor then
                  null
                else if isDerivation obj then
                  obj
                else if builtins.isAttrs obj then
                  (if obj == { } then null else obj |> mapAttrs (_: filter) |> filterAttrs (_: attr: attr != null))
                else
                  null;
            in
            self.legacyPackages
            |> filterAttrs (system: _: system == "x86_64-linux")
            |> mapAttrs (_: filter)
            |> mapAttrs (_: (flip removeAttrs) [ "_bartPackages" ]);

          nixosModules = import ./modules;
        };

        perSystem =
          {
            pkgs,
            system,
            lib,
            ...
          }:

          let
            inherit (lib) filterAttrs isDerivation;

            packages = pkgs.callPackage ./. { inherit system; };
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [
                  "olm-3.2.16"
                  "github-readme-stats-0-unstable-2026-05-19"
                ];
              };
              overlays = [
                self.overlays.suppressSystemWarning
                self.overlays.default
              ];
            };

            treefmt = {
              programs.nixfmt.enable = true;
              programs.deadnix.enable = true;
              programs.statix.enable = true;
              programs.keep-sorted.enable = true;
            };

            packages = filterAttrs (_: isDerivation) packages;
            legacyPackages = packages;

            checks = import ./tests { inherit lib self; } |> mapAttrs (_: pkgs.testers.runNixOSTest);
          };
      }
    );
}
