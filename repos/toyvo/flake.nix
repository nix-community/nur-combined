{
  description = "My personal NUR repository";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
    ];
  };
  inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      devshell,
      flake-parts,
      nixpkgs,
      treefmt-nix,
      self,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      pkgsDir = "${self}/pkgs";
      libDir = "${self}/lib";
      overlaysDir = "${self}/overlays";
      modulesDir = "${self}/modules";
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        moduleWithSystem,
        withSystem,
        ...
      }:
      let
        ourLib = (import libDir { inherit lib; });
        lib' = lib.recursiveUpdate lib ourLib;
      in
      {
        flake = {
          lib = ourLib;
          overlays = lib'.importDirRecursive overlaysDir;
          modules = lib'.importDirRecursive modulesDir;
        };
        systems = lib.systems.flakeExposed;
        imports = [
          devshell.flakeModule
          flake-parts.flakeModules.easyOverlay
          treefmt-nix.flakeModule
        ];
        perSystem =
          {
            self',
            config,
            pkgs,
            system,
            ...
          }:
          with lib';
          let
            pkgs' = recursiveUpdate pkgs { lib = lib'; };
            ourPackages = callDirPackageWithRecursive pkgs' pkgsDir;
          in
          {
            legacyPackages = ourPackages // {
              inherit (self) lib overlays modules;
              maintainers = pkgs.callPackage "${self}/maintainers" { };
            };
            packages = flakePackages system ourPackages;
            overlayAttrs.toyvo = ourPackages;
            # we get infinite recursion on freebsd with `nix flake show`, not investigating
            checks = lib.mkIf (system != "x86_64-freebsd") (flakeChecks system self'.packages);

            treefmt = {
              programs = {
                nixfmt.enable = true;
                yamlfmt.enable = true;
                mdformat.enable = true;
              };
            };
            devshells.default = {
              imports = [ "${devshell}/extra/git/hooks.nix" ];
              git.hooks = {
                enable = true;
                pre-commit.text = ''
                  echo "Stashing unstaged changes..."
                  git commit --no-verify -m 'Save index'
                  old_stash=$(git rev-parse -q --verify refs/stash)
                  git stash push -m 'Unstaged changes'
                  new_stash=$(git rev-parse -q --verify refs/stash)
                  git reset --soft HEAD^

                  echo "Formatting..."
                  nix fmt

                  git add -u

                  if [ "$old_stash" != "$new_stash" ]; then
                      echo "Restoring unstaged changes..."
                      git stash pop
                  else
                      echo "No unstaged changes to restore."
                  fi
                '';
                pre-push.text = ''
                  echo "Check evaluation"
                  nix flake show
                  echo "Build nix packages"
                  nix run nixpkgs#nix-fast-build -- --skip-cached --flake ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem)" -j 1 --eval-workers 1
                  echo "Check evaluation"
                  NIX_PAGER=cat nix-env -f . -qa \* --meta --xml \
                    --allowed-uris https://static.rust-lang.org \
                    --option allow-import-from-derivation true \
                    --drv-path --show-trace \
                    -I $PWD
                  echo "Build nix packages"
                  nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached maintainers/ci.nix -A cacheOutputs
                '';
              };
            };
          };
      }
    );
}
