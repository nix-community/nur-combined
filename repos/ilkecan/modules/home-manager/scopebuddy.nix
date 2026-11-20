{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatLines
    escapeShellArg
    escapeShellArgs
    isBool
    literalExpression
    literalMD
    mapAttrs'
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optional
    types
    ;

  cfg = config.programs.scopebuddy;

  configOptions = {
    environment = mkOption {
      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            int
          ])
        );
      default = { };
      example = {
        XKB_DEFAULT_LAYOUT = "us";
        TZ = null;
      };
      description = ''
        Environment variables exported for gamescope and the game. A `null` value unsets the variable.
      '';
    };

    settings = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
      default = { };
      example = {
        SCB_AUTO_HDR = true;
        SCB_DEBUG = true;
      };
      description = ''
        ScopeBuddy's own variables, such as `SCB_DEBUG`. They are not exported, so the game does not see them; use `environment` for variables meant for the game. Booleans are written as `1` and `0`. `SCB_CONF` and `SCB_STEAMARGIGNORE` have no effect here because ScopeBuddy uses them before loading the configuration files; set them in the launch options instead.
      '';
    };

    gamescopeArgs = mkOption {
      type = with types; nullOr (listOf str);
      default = null;
      example = [
        "-W"
        "1920"
        "-H"
        "1080"
        "-r"
        "120"
      ];
      description = ''
        Arguments for gamescope, written to `SCB_GAMESCOPE_ARGS`. ScopeBuddy ignores them when gamescope arguments are given before `--` in the launch options, unless `SCB_APPENDMODE` is set.
      '';
    };

    commandPrefix = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [ "gamemoderun" ];
      description = ''
        Command prepended to the game command (Steam's `%command%`). It runs inside gamescope when gamescope is used. A prefix from an app configuration is prepended to the prefix of the profile, so it runs first.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Bash appended to the configuration file. The game command, including `commandPrefix`, is available in `$command`.
      '';
    };
  };

  toShellValue = value: if isBool value then (if value then "1" else "0") else escapeShellArg value;

  renderConfig =
    c:
    concatLines (
      mapAttrsToList (
        name: value: if value == null then "unset ${name}" else "export ${name}=${toShellValue value}"
      ) c.environment
      ++ mapAttrsToList (name: value: "${name}=${toShellValue value}") c.settings
      # ScopeBuddy passes the gamescope arguments and the command through
      # `eval`, so each argument is quoted once more.
      ++ optional (
        c.gamescopeArgs != null
      ) "SCB_GAMESCOPE_ARGS=${escapeShellArg (escapeShellArgs c.gamescopeArgs)}"
      ++ optional (
        c.commandPrefix != [ ]
      ) "command=${escapeShellArg (escapeShellArgs c.commandPrefix)}\" $command\""
      ++ optional (c.extraConfig != "") c.extraConfig
    );

  configFiles =
    dir: configs:
    mapAttrs' (
      name: c: nameValuePair "scopebuddy/${dir}${name}.conf" { text = renderConfig c; }
    ) configs;
in
{
  meta.maintainers = with lib.maintainers; [ ilkecan ];

  options.programs.scopebuddy = configOptions // {
    enable = mkEnableOption "ScopeBuddy, a manager script for running games in gamescope";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.callPackage ../../packages/scopebuddy/package.nix { };
      defaultText = literalMD "the `scopebuddy` package from this repository, built with `pkgs`";
      description = ''
        The ScopeBuddy package to install, or `null` to not install it.
      '';
    };

    profiles = mkOption {
      type = types.attrsOf (types.submodule { options = configOptions; });
      default = { };
      example = literalExpression ''
        {
          noscope.environment.PROTON_ENABLE_WAYLAND = "1";
        }
      '';
      description = ''
        Configuration files other than `scb.conf`, which is configured by the top-level options. In Steam's Game Mode ScopeBuddy reads `gamemode.conf`. Otherwise it reads `<name>.conf` when `SCB_CONF=<name>.conf` is given in the launch options, or `noscope.conf` when `SCB_NOSCOPE=1` is given in the launch options or gamescope is not found. Each launch reads only one of these files, so the top-level options do not apply when another profile is used.
      '';
    };

    apps = mkOption {
      type = types.attrsOf (types.submodule { options = configOptions; });
      default = { };
      example = literalExpression ''
        {
          "1674890".environment.TZ = null;
        }
      '';
      description = ''
        Per-game configuration, read after the profile and able to override it. Keys are Steam app IDs, `heroic/<appName>` and `ubisoft/<id>` for games ScopeBuddy detects from Heroic and Ubisoft Connect, or any value set as `SCB_APPID` in the launch options or the profile.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.profiles ? scb;
        message = "programs.scopebuddy.profiles.scb: configure `scb.conf` with the top-level `programs.scopebuddy` options.";
      }
    ];

    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    # ScopeBuddy switches to these profiles on its own (SCB_NOSCOPE=1 or no
    # gamescope, Game Mode) and writes an example profile to a missing one,
    # which would then block home-manager from managing that file.
    programs.scopebuddy.profiles = {
      gamemode = { };
      noscope = { };
    };

    xdg.configFile = {
      "scopebuddy/scb.conf".text = renderConfig cfg;
    }
    // configFiles "" cfg.profiles
    // configFiles "AppID/" cfg.apps;
  };
}
