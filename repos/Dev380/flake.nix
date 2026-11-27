{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The dfmic checkout the package builds. Pinning it here rather than fetching
    # a tarball inside the package means `nix flake update dfmic` is the whole
    # upgrade, and `--override-input dfmic path:/home/me/dfmic` builds a local
    # checkout without editing anything.
    dfmic = {
      url = "github:Dev380/dfmic";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    dfmic,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    # Flake inputs are store paths. `dfmicSrc` rather than `src` because
    # `callPackage` fills `src` from nixpkgs' top-level alias.
    dfmicSrc = dfmic;
  in rec {
    legacyPackages = (
      forAllSystems (
        system: (
          with {
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [];
            };
          };
            import ./default.nix {inherit pkgs dfmicSrc;}
        )
      )
    );
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

    # The overlay NUR builds for a repository, so this flake can be consumed the
    # same way as the aggregate: `nixpkgs.overlays = [ my-nur.overlays.default ]`
    # puts the packages on a plain `pkgs`.
    #
    # Only `dfmic` is exposed, and `lib` is deliberately not carried over:
    # `default.nix` has a `lib` attribute of this repository's own helper
    # functions, and putting that on `pkgs` shadows `pkgs.lib` for everything
    # downstream — `lib.optionals` and friends then vanish, and the failures
    # surface inside unrelated packages.
    overlays.default = final: _prev: {
      dfmic = final.callPackage ./pkgs/dfmic {dfmicSrc = dfmic;};
    };
    ciJobs = let
      lib = nixpkgs.lib;
      isBuildable = platform: p: ((!p.meta.broken) && (lib.meta.availableOn {system = platform;} p));
      isCacheable = p: !(p.preferLocalBuild or false);

      filterNurAttrs = with lib;
        platform: attrs:
          filterAttrs (_: v: isDerivation v && isBuildable platform v && isCacheable v) attrs;
    in
      lib.attrsets.genAttrs systems (name: (filterNurAttrs name packages."${name}"))
      // {
        aarch64-linux = filterNurAttrs "aarch64-linux" (
          import ./default.nix {
            inherit dfmicSrc;
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              crossSystem.config = "aarch64-unknown-linux-gnu";
              config.allowUnfree = true;
              overlays = [];
            };
          }
        );
      };
  };
}
