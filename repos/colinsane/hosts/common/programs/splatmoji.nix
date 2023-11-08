# borrows from:
# - default config: <https://github.com/cspeterson/splatmoji/blob/master/splatmoji.config>
# - wayland: <https://github.com/cspeterson/splatmoji/issues/32#issuecomment-830862566>
{ pkgs, ... }:

{
  sane.programs.splatmoji = {
    persist.byStore.plaintext = [ ".local/state/splatmoji" ];
    fs.".config/splatmoji/splatmoji.config".symlink.text = ''
      # XXX doesn't seem to understand ~ as shorthand for `$HOME`
      history_file=/home/colin/.local/state/splatmoji/history
      history_length=5
      paste_command=${pkgs.wtype}/bin/wtype -M Ctrl -k v
      # rofi_command=${pkgs.wofi}/bin/wofi --dmenu --insensitive --cache-file /dev/null
      rofi_command=${pkgs.fuzzel}/bin/fuzzel -d -i -w 60
      xdotool_command=${pkgs.wtype}/bin/wtype
      xsel_command=${pkgs.findutils}/bin/xargs ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  };
}
