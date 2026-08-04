{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    ;
  cfg = config.programs.peaclock;
  alias = {
    peaclock = "${cfg.package}/bin/peaclock --config-dir ${config.home.homeDirectory}/.config/peaclock";
  };

in
{
  options.programs.peaclock = {
    enable = mkEnableOption "peaclock";

    package = mkPackageOption pkgs "peaclock" { };

    settings = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Settings to configure peaclock. See
        <https://github.com/octobanana/peaclock/tree/master/cfg> for examples
        of configuration files.
      '';
    };

    enableAlias = mkEnableOption "configuration alias for peacock (if settings are provided)";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableAlias -> cfg.settings != null;
        message = "Cannot enable aliases if there are no settings provided";
      }
    ];

    home.packages = [ pkgs.peaclock ];

    xdg.configFile."peaclock/config" = mkIf (cfg.settings != null) {
      text = cfg.settings;
    };

    programs.bash.shellAliases = mkIf cfg.enableAlias alias;

    programs.fish = mkMerge [
      (mkIf (!config.programs.fish.preferAbbrs) {
        shellAliases = mkIf cfg.enableAlias alias;
      })

      (mkIf config.programs.fish.preferAbbrs {
        shellAbbrs = mkIf cfg.enableAlias alias;
      })
    ];

    programs.zsh.shellAliases = mkIf cfg.enableAlias alias;
  };
}
