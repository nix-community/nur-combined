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

      [[keyboard.bindings]]
      mods = "Control"
      key = "PageDown"
      action = "ScrollPageDown"

      [[keyboard.bindings]]
      mods = "Control|Shift"
      key = "PageUp"
      action = "ScrollPageUp"

      [[keyboard.bindings]]
      mods = "Control|Shift"
      key = "PageDown"
      action = "ScrollPageDown"

      # disable OS shortcuts which leak through...
      # see sway config or sane-input-handler for more info on why these leak through
      [[keyboard.bindings]]
      key = "AudioVolumeUp"
      action = "None"
      [[keyboard.bindings]]
      key = "AudioVolumeDown"
      action = "None"
      [[keyboard.bindings]]
      key = "Power"
      action = "None"
      [[keyboard.bindings]]
      key = "PowerOff"
      action = "None"
    '';
  };
}
