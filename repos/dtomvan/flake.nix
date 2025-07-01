{
  description = "Packages from my personal dotfiles";

  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        defaultNix = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage newScope;
          directory = ./pkgs;
        };
        flattenPkgs = (import lib/flatten.nix { inherit pkgs; });
        flakePackages = flattenPkgs defaultNix;
        warnPackages =
          if system != "x86_64-linux" then
            pkgs.lib.warn "dtomvan/nur-packages: only x86_64-linux builds are tested, use at own risk" flakePackages
          else
            flakePackages;
      in
      {
        legacyPackages = warnPackages;
        packages = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) warnPackages;

        formatter = pkgs.nixfmt-tree;
        # doesn't work like a check because those are builds and are sandboxed
        # why must flake apps be this way?
        apps.check-nur-eval =
          let
            script = pkgs.writeShellApplication {
              name = "check-nur-eval";
              runtimeInputs = with pkgs; [
                nix
                jq
              ];
              text = ''
                cd ${./.}
                nix-env -f . -qa \* --meta \
                  --allowed-uris https://static.rust-lang.org \
                  --option restrict-eval true \
                  --option allow-import-from-derivation true \
                  --drv-path --show-trace \
                  -I nixpkgs=${nixpkgs} \
                  -I ./ \
                  --json | jq -r 'values | .[].name'
              '';
            };
          in
          {
            type = "app";
            program = "${pkgs.lib.getExe script}";
          };
      }
    );
}
