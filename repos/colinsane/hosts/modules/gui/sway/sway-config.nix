{ config, pkgs }:
let
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
  sed = "${pkgs.gnused}/bin/sed";
  wtype = "${pkgs.wtype}/bin/wtype";
  launcher_cmd = fuzzel;
  terminal_cmd = "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec";
  lock_cmd = "${pkgs.swaylock}/bin/swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
  # TODO: use pipewire controls?
  vol_up_cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5";
  vol_down_cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5";
  mute_cmd = "${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
  # "bookmarking"/snippets inspired by Luke Smith:
  # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
  snip_cmd = pkgs.writeShellScript "type_snippet.sh" ''
    snippet=$(cat ${../snippets.txt} ~/.config/sane-sway/snippets.txt | \
      ${fuzzel} -d -i -w 60 | \
      ${sed} 's/ #.*$//')
    ${wtype} "$snippet"
  '';
  # TODO: splatmoji release > 1.2.0 should allow `-s none` to disable skin tones
  emoji_cmd = "${pkgs.splatmoji}/bin/splatmoji -s medium-light type";

  xwayland = "disable";
in pkgs.substituteAll {
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
    xwayland
  ;
  inherit (config)
    background
    brightness_down_cmd
    brightness_up_cmd
    extra_lines
    screenshot_cmd
    status_cmd
    font
    mod
    workspace_layout
  ;
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  waybar = "${pkgs.waybar}/bin/waybar";
}
