{ config
, substituteAll
, swayCfg
}:
substituteAll {
  src = ./sway-config;
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
