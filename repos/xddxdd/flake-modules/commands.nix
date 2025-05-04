{
  devshell,
  flake-parts-lib,
  ...
}:
{
  imports = [ devshell.flakeModule ];

  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      pkgs,
      lib,
      config,
      ...
    }:
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

        devshells.default = {
          commands = lib.mapAttrsToList (n: _v: {
            name = n;
            command = "exec nix run .#${n} -- \"$@\"";
          }) apps;

          motd = lib.mkDefault "";

          packages = lib.optionals (config ? pre-commit) (
            config.pre-commit.settings.enabledPackages
            ++ [
              config.pre-commit.settings.package
            ]
          );

          devshell.startup = lib.optionalAttrs (config ? pre-commit) {
            pre-commit.text = config.pre-commit.installationScript;
          };
        };
      };
    }
  );
}
