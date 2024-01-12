# alacritty terminal emulator
# - config options: <https://github.com/alacritty/alacritty/blob/master/extra/man/alacritty.5.scd>
#   - `man 5 alacritty`
#   - defaults: <https://github.com/alacritty/alacritty/releases>  -> alacritty.yml
# - irc: #alacritty on libera.chat
{ lib, ... }:
{
  sane.programs.alacritty = {
    env.TERMINAL = lib.mkDefault "alacritty";
    fs.".config/alacritty/alacritty.toml".symlink.text = ''
      [font]
      size = 14

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
    '';
  };
}
