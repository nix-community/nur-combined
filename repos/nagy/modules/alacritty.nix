{
  config,
  pkgs,
  lib,
  ...
}:

# You will receive a package that has a `ala` terminal launcher and multiple scripts called
# `ala-${name}` as defined by the hmmodules argument. With these scripts you can switch the setting
# of the running terminal to that of the corresponding home-manager module setting

let
  alacrittyMyTheme = isDark: {
    # Post about making alacritty responsive:
    # https://arslan.io/2021/02/15/automatic-dark-mode-for-terminal-applications/
    programs.alacritty = {
      enable = true;
      settings = {
        # disable url launcher
        hints.enabled = [ ];
        # 100k is the max
        scrolling = {
          history = 100 * 1000;
        };
        # xterm colors
        # https://github.com/eendroroy/alacritty-theme/blob/master/themes/xterm.yaml
        colors = {
          primary = {
            background = if isDark then "0x000000" else "0xffffff";
            foreground = if isDark then "0xffffff" else "0x000000";
          };
          # Normal colors
          normal = {
            black = "0x000000";
            # # modus-themese fg colors
            # red = if isDark then "#ff5f59" else "#a60000";
            # green = if isDark then "#44bc44" else "#006800";
            # yellow = if isDark then "#d0bc00" else "#6f5500";
            # blue = if isDark then "#2fafff" else "#0031a9";
            # magenta = if isDark then "#feacd0" else "#721045";
            # cyan = if isDark then "#00d3d0" else "#005e8b";
            # modus-themese fg intense colors
            red = if isDark then "#ff5f5f" else "#d00000";
            green = if isDark then "#44df44" else "#008900";
            yellow = if isDark then "#efef00" else "#808000";
            blue = if isDark then "#338fff" else "0x0000ee";
            magenta = if isDark then "#ff66ff" else "#dd22dd";
            cyan = if isDark then "#00eff0" else "#008899";
            # white = "0xe5e5e5";
            white = "0xffffff";
          };
          # Bright colors
          bright = {
            black = "0x7f7f7f";
            # modus-themese fg intense colors
            red = if isDark then "#ff5f5f" else "#d00000";
            green = if isDark then "#44df44" else "#008900";
            yellow = if isDark then "#efef00" else "#808000";
            blue = if isDark then "#338fff" else "0x0000ee";
            magenta = if isDark then "#ff66ff" else "#dd22dd";
            cyan = if isDark then "#00eff0" else "#008899";
            white = "0xffffff";
          };
        };
        keyboard.bindings = [
          {
            key = "PageUp";
            mode = "Vi|~Search";
            action = "ScrollPageUp";
          }
          {
            key = "PageDown";
            mode = "Vi|~Search";
            action = "ScrollPageDown";
          }
          {
            key = "Home";
            mode = "Vi|~Search";
            action = "ScrollToTop";
          }
          {
            key = "End";
            mode = "Vi|~Search";
            action = "ScrollToBottom";
          }
          {
            key = "Slash";
            mode = "Vi|~Search";
            action = "SearchForward";
            # even this this entry is already in the default
            # configuration, because this line is not present there, the
            # bindings has no effect on qwertz keyboards.
            mods = "Shift";
          }
        ];
      };
    };
  };
  # A attrset of home-manager modules that define alacritty configs. You can switch to these with the
  # `ala-${name}` script.
  hmmodules = {
    day = alacrittyMyTheme false;
    night = alacrittyMyTheme true;
  };
  alacrittyLiveConfigPath = "/run/user/$UID/alacritty-conf.json";
  getAlaText =
    hmmodule:
    let
      tomlFormat = pkgs.formats.toml { };
      cfg = hmmodule.programs.alacritty;
      tomlFile = tomlFormat.generate "alacritty.toml" cfg.settings;
    in
    pkgs.writeText "ala-config" (lib.replaceStrings [ "\\\\" ] [ "\\" ] (builtins.readFile tomlFile));
  mkAlacrittySwitcher =
    name: hmmodule:
    (pkgs.writeShellScriptBin "ala-${name}" ''
      cat < '${getAlaText hmmodule}' > ${alacrittyLiveConfigPath}
    '');
  alacrittyCombined = pkgs.symlinkJoin {
    name = "ala-switchers";
    paths =
      [
        (pkgs.writeShellScriptBin "alacritty" ''
          exec ${pkgs.alacritty}/bin/alacritty \
            --option live_config_reload=true \
            --config-file ${alacrittyLiveConfigPath} "$@"
        '')
      ]
      ++ (lib.mapAttrsToList mkAlacrittySwitcher hmmodules)
      ++ [ pkgs.alacritty ];
  };

  cfg = config.nagy.alacritty;
in
{
  imports = [ ./shortcommands.nix ];

  options.nagy.alacritty = {
    enable = lib.mkEnableOption "alacritty config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      alacrittyCombined
    ];

  };
}
