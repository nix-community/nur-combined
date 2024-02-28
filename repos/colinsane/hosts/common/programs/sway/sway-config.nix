{ config
, substituteAll
, swayCfg
, writeShellApplication
}:
let
  # TODO: port this snip_cmd_pkg to an ordinary `sane.programs`
  prog = config.sane.programs;
  # "bookmarking"/snippets inspired by Luke Smith:
  # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
  snip_cmd_pkg = writeShellApplication {
    name = "type-snippet";
    runtimeInputs = [
      prog.rofi.package
      prog.gnused.package
      prog.wtype.package
    ];
    text = ''
      snippet=$(cat ${./snippets.txt} ~/.config/sane-sway/snippets.txt | \
        rofi -dmenu | \
        sed 's/ #.*$//')
      wtype "$snippet"
    '';
  };
  snip_cmd = "${snip_cmd_pkg}/bin/type-snippet";
  # TODO: splatmoji release > 1.2.0 should allow `-s none` to disable skin tones
in substituteAll {
  src = ./sway-config;
  inherit snip_cmd;
  inherit (swayCfg)
    background
    extra_lines
    screenshot_cmd
    font
    mod
    workspace_layout
  ;
  xwayland = if config.sane.programs.xwayland.enabled then "enable" else "disable";
}
