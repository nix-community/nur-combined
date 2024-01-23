{ config
, substituteAll
, swayCfg
, writeShellScript
}:
let
  prog = config.sane.programs;
  # TODO: stop referring to all of these by absolute path.
  fuzzel = "${prog.fuzzel.package}/bin/fuzzel";
  sed = "${prog.gnused.package}/bin/sed";
  wtype = "${prog.wtype.package}/bin/wtype";
  launcher_cmd = fuzzel;
  terminal_cmd = "${prog.xdg-terminal-exec.package}/bin/xdg-terminal-exec";
  lock_cmd = "${prog.swaylock.package}/bin/swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
  # TODO: use pipewire controls?
  vol_up_cmd = "${prog.pulsemixer.package}/bin/pulsemixer --change-volume +5";
  vol_down_cmd = "${prog.pulsemixer.package}/bin/pulsemixer --change-volume -5";
  mute_cmd = "${prog.pulsemixer.package}/bin/pulsemixer --toggle-mute";
  # "bookmarking"/snippets inspired by Luke Smith:
  # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
  snip_cmd = writeShellScript "type_snippet.sh" ''
    snippet=$(cat ${../snippets.txt} ~/.config/sane-sway/snippets.txt | \
      ${fuzzel} -d -i -w 60 | \
      ${sed} 's/ #.*$//')
    ${wtype} "$snippet"
  '';
  # TODO: splatmoji release > 1.2.0 should allow `-s none` to disable skin tones
  emoji_cmd = "${prog.splatmoji.package}/bin/splatmoji -s medium-light type";
in substituteAll {
  src = ./sway-config;
  inherit
    emoji_cmd
    launcher_cmd
    lock_cmd
    mute_cmd
    snip_cmd
    terminal_cmd
    vol_down_cmd
    vol_up_cmd
  ;
  inherit (swayCfg)
    background
    brightness_down_cmd
    brightness_up_cmd
    extra_lines
    screenshot_cmd
    font
    mod
    workspace_layout
  ;
  xwayland = if swayCfg.xwayland then "enable" else "disable";
  playerctl = "${prog.playerctl.package}/bin/playerctl";
  waybar = "${prog.waybar.package}/bin/waybar";
}
