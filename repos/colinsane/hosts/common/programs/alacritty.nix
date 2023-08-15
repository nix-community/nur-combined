# alacritty terminal emulator
# - config options: <https://github.com/alacritty/alacritty/blob/master/extra/man/alacritty.5.scd>
#   - `man 5 alacritty`
#   - defaults: <https://github.com/alacritty/alacritty/releases>  -> alacritty.yml
# - irc: #alacritty on libera.chat
{ lib, ... }:
{
  sane.programs.alacritty = {
    env.TERMINAL = lib.mkDefault "alacritty";
    # note: alacritty will switch to .toml config in 13.0 release
    # - run `alacritty migrate` to convert the yaml to toml
    fs.".config/alacritty/alacritty.yml".symlink.text = ''
      font:
        size: 14

      key_bindings:
        - { key: N,         mods: Control,        action: CreateNewWindow }
        - { key: PageUp,    mods: Control,        action: ScrollPageUp }
        - { key: PageDown,  mods: Control,        action: ScrollPageDown }
        - { key: PageUp,    mods: Control|Shift,  action: ScrollPageUp }
        - { key: PageDown,  mods: Control|Shift,  action: ScrollPageDown }
    '';
  };
}
