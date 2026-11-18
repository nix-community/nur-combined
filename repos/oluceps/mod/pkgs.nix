{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    {
      pkgs,
      lib,
      system,
      config,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays =
          map
            (
              i:
              if inputs.${i}.overlays ? "default" then inputs.${i}.overlays.default else inputs.${i}.overlays.${i}
            )
            [
              "fenix"
              "self"
              "nuenv"
            ];
        config = {
          # radicle-node is in the dev shell. The package is marked insecure
          # because private-repository traffic is neither encrypted nor
          # authenticated. Pin the exact version instead of allowing all
          # insecure packages, and do not use it for private repositories.
          permittedInsecurePackages = [ "radicle-node-1.10.3" ];
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "veracrypt"
              "tetrio-desktop"
              # claude-code is unfree. It is also the package that
              # pkgs/claude-code/patchClaude.nix patches, and the patched build is
              # exported as packages.claudeCodeNixpkgsPatched, so the name has to
              # be allowed for that attribute to evaluate outside NixOS.
              "claude-code"
            ];
        };
      };

      overlayAttrs = config.packages;
      packages =
        (lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ../pkgs/by-name;
        })
        // {
          default = pkgs.symlinkJoin {
            name = "user-pkgs";
            paths = import ../user-pkgs.nix { inherit pkgs; };
          };
        };
    };
}
