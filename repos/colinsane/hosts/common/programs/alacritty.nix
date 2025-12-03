# alacritty terminal emulator
# - config options: <https://github.com/alacritty/alacritty/blob/master/extra/man/alacritty.5.scd>
#   - `man 5 alacritty`
#   - defaults: <https://github.com/alacritty/alacritty/releases>  -> alacritty.yml
# - irc: #alacritty on libera.chat
{ config, lib, ... }:
let
  cfg = config.sane.programs.alacritty;
in
{
  sane.programs.alacritty = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.fontSize = mkOption {
          type = types.int;
          default = 14;
        };
      };
    };

    sandbox.enable = false;
    env.TERMINAL = lib.mkDefault "alacritty";

    fs.".config/alacritty/alacritty.toml".symlink.text = ''
      [font]
      size = ${builtins.toString cfg.config.fontSize}


      [colors]
      # draw_bold_text_with_bright_colors = true
      # footer_bar = ...
      # line_indicator = ...

      [colors.bright]
      # white = "#ffffff"

      [colors.cursor]
      cursor = "#404040"
      text = "#c0c0c0"

      [colors.dim]
      # white = "#ffffff"

      [colors.hints]

      [colors.normal]
      # white = "#ffffff"

      [colors.primary]
      # black-on-white scheme:
      background = "#ffffff"
      foreground = "#181818"

      # defaults:
      # background = "#181818"
      # foreground = "#d8d8d8"
      # alacritty will auto-calculate these from other colors if omitted
      # bright_foreground = "None"
      # dim_foreground = "#828482"

      [colors.search]


      [cursor]
      # blink_interval (ms)
      blink_interval = 600
      # blink_timeout (in seconds): 0 = never stop blinking
      blink_timeout = 0

      [cursor.style]
      blinking = "Always"


      [[keyboard.bindings]]
      mods = "Control"
      key = "N"
      action = "CreateNewWindow"

      [[keyboard.bindings]]
      mods = "Control"
      key = "PageUp"
      action = "ScrollPageUp"
      #
      [[keyboard.bindings]]
      mods = "Control"
      key = "PageDown"
      action = "ScrollPageDown"
      #
      [[keyboard.bindings]]
      mods = "Control|Shift"
      key = "PageUp"
      action = "ScrollPageUp"
      #
      [[keyboard.bindings]]
      mods = "Control|Shift"
      key = "PageDown"
      action = "ScrollPageDown"

      [[keyboard.bindings]]
      # disable builtin Ctrl+Shift+Space => visual selection binding
      mods = "Control|Shift"
      key = "Space"
      action = "None"

      # disable OS shortcuts which leak through...
      # see sway config or sane-input-handler for more info on why these leak through
      [[keyboard.bindings]]
      key = "AudioVolumeUp"
      action = "None"
      #
      [[keyboard.bindings]]
      key = "AudioVolumeDown"
      action = "None"
      #
      [[keyboard.bindings]]
      key = "Power"
      action = "None"
      #
      [[keyboard.bindings]]
      key = "PowerOff"
      action = "None"


     [selection]
     # make double-click-to-select not select quote marks from nix («») or wget (‘’)
     # semantic_escape_chars default: ",│`|:\"' ()[]{}<>\t"
     # TODO: i could probably send this upstream
     semantic_escape_chars = ",│`|:\"' ()[]{}<>\t‘’«»"
    '';
  };
}
