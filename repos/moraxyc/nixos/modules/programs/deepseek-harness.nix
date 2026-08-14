{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.deepseek-harness = {
    enable = lib.mkEnableOption "the DeepSeek Harness dsh CLI with declarative profiles";

    package = lib.mkPackageOption pkgs "deepseek-harness" { };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            plugins = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              description = ''
                dsh plugin packages enabled for this profile, e.g.
                `pkgs.deepseek-harness-tui`. Their `passthru.dshBundles` names are
                stacked onto the shared `@deepseek-ai/dsh-base` layer. Plugins
                listed here are also composed into the installed package.
              '';
            };

            patch = lib.mkOption {
              type = lib.types.lines;
              default = lib.generators.toYAML { } [ ];
              description = ''
                The profile's `cordis.patch.yml` user layer, applied after every
                bundle layer.
              '';
            };
          };
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          tui.plugins = [ pkgs.deepseek-harness-tui ];
        }
      '';
      description = ''
        dsh profiles seeded into `$DSH_HOME/profiles/<name>` (default
        `~/.dsh/profiles`) on first use, so `dsh --profile <name>` works out
        of the box. Existing profile files are never overwritten.
      '';
    };
  };

  config = lib.mkIf config.programs.deepseek-harness.enable {
    environment.systemPackages = [
      (config.programs.deepseek-harness.package.withProfiles config.programs.deepseek-harness.profiles)
    ];
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
