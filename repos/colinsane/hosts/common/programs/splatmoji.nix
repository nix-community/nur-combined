# borrows from:
# - default config: <https://github.com/cspeterson/splatmoji/blob/master/splatmoji.config>
# - wayland: <https://github.com/cspeterson/splatmoji/issues/32#issuecomment-830862566>
{ pkgs, ... }:

{
  sane.programs.splatmoji = {
    persist.plaintext = [ ".local/state/splatmoji" ];
    fs.".config/splatmoji/splatmoji.config".symlink.text = ''
      # XXX doesn't seem to understand ~ as shorthand for `$HOME`
      history_file=/home/colin/.local/state/splatmoji/history
      history_length=5
      # TODO: wayland equiv
      paste_command=xdotool key ctrl+v
      # rofi_command=${pkgs.wofi}/bin/wofi --dmenu --insensitive --cache-file /dev/null
      rofi_command=${pkgs.fuzzel}/bin/fuzzel -d -i -w 60
      xdotool_command=${pkgs.wtype}/bin/wtype
      # TODO: wayland equiv
      xsel_command=xsel -b -i
    '';
  };
}
