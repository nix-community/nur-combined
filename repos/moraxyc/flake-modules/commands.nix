{ lib, flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    {
      options.commands = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Command names and their bash script content";
      };
      config = rec {
        apps = lib.mapAttrs (n: v: {
          type = "app";
          program = pkgs.writeShellScriptBin n v;
        }) config.commands;

        devShells.default = pkgs.mkShell (
          {
            buildInputs = lib.mapAttrsToList (
              n: _v:
              pkgs.writeShellScriptBin n ''
                exec nix run .#${n} -- "$@"
              ''
            ) apps;
          }
          // (lib.optionalAttrs (config ? pre-commit) {
            nativeBuildInputs = config.pre-commit.settings.enabledPackages ++ [
              config.pre-commit.settings.package
            ];
            shellHook = config.pre-commit.installationScript;

          })
        );
      };
    }
  );
}
