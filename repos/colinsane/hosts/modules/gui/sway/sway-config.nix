{ config
, substituteAll
, swayCfg
, writeShellApplication
}:
let
  prog = config.sane.programs;
  # TODO: move all of this inline into the non-nix sway-config
  launcher_cmd = "fuzzel";
  terminal_cmd = "xdg-terminal-exec";
  lock_cmd = "swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
  # TODO: use pipewire controls?
  vol_up_cmd = "pulsemixer --change-volume +5";
  vol_down_cmd = "pulsemixer --change-volume -5";
  mute_cmd = "pulsemixer --toggle-mute";
  # "bookmarking"/snippets inspired by Luke Smith:
  # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
  snip_cmd_pkg = writeShellApplication {
    name = "type-snippet";
    runtimeInputs = [
      prog.fuzzel.package
      prog.gnused.package
      prog.wtype.package
    ];
    text = ''
      snippet=$(cat ${../snippets.txt} ~/.config/sane-sway/snippets.txt | \
        fuzzel -d -i -w 60 | \
        sed 's/ #.*$//')
      wtype "$snippet"
    '';
  };
  snip_cmd = "${snip_cmd_pkg}/bin/type-snippet";
  # TODO: splatmoji release > 1.2.0 should allow `-s none` to disable skin tones
  emoji_cmd = "splatmoji -s medium-light type";
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
  playerctl = "playerctl";
  waybar = "waybar";
}
