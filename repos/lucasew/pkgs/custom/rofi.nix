{ writeShellScriptBin
, symlinkJoin
, rofi
, colors ? null
, lib
}:
let
  mkRofi = flags: "${rofi}/bin/rofi ${builtins.concatStringsSep " " flags}";
  commonFlags = [
    "-show-icons"
    "-theme"
  ]
  ++ [
    (if colors == null then "gruvbox" else (let
      inherit (colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
    in builtins.toFile "base16.rasi" ''
* {
    red:                         #${base08};
    blue:                        #${base0D};
    lightfg:                     #${base04};
    lightbg:                     #${base01};
    foreground:                  #${base05};
    background:                  #${base00};
    background-color:            #${base00};
    separatorcolor:              @foreground;
    border-color:                @foreground;
    selected-normal-foreground:  @lightbg;
    selected-normal-background:  @lightfg;
    selected-active-foreground:  @background;
    selected-active-background:  @blue;
    selected-urgent-foreground:  @background;
    selected-urgent-background:  @red;
    normal-foreground:           @foreground;
    normal-background:           @background;
    active-foreground:           @blue;
    active-background:           @background;
    urgent-foreground:           @red;
    urgent-background:           @background;
    spacing:                     2;
}
window {
    background-color: @background;
    border:           1;
    padding:          5;
}
mainbox {
    border:           0;
    padding:          0;
}
message {
    border:           1px dash 0px 0px ;
    border-color:     @separatorcolor;
    padding:          1px ;
}
textbox {
    text-color:       @foreground;
}
listview {
    fixed-height:     0;
    border:           2px dash 0px 0px ;
    border-color:     @separatorcolor;
    spacing:          2px ;
    scrollbar:        true;
    padding:          2px 0px 0px ;
}
element-text, element-icon {
    background-color: inherit;
    text-color:       inherit;
}
element {
    border:           0;
    padding:          1px ;
}
element normal.normal, element alternate.normal {
    background-color: @normal-background;
    text-color:       @normal-foreground;
}
element normal.urgent, element alternate.urgent {
    background-color: @urgent-background;
    text-color:       @urgent-foreground;
}
element normal.active, element alternate.active {
    background-color: @active-background;
    text-color:       @active-foreground;
}
element selected.normal {
    background-color: @selected-normal-background;
    text-color:       @selected-normal-foreground;
}
element selected.urgent {
    background-color: @selected-urgent-background;
    text-color:       @selected-urgent-foreground;
}
element selected.active {
    background-color: @selected-active-background;
    text-color:       @selected-active-foreground;
}
scrollbar {
    width:            4px ;
    border:           0;
    handle-color:     @normal-foreground;
    handle-width:     8px ;
    padding:          0;
}
sidebar {
    border:           2px dash 0px 0px ;
    border-color:     @separatorcolor;
}
button {
    spacing:          0;
    text-color:       @normal-foreground;
}
button selected {
    background-color: @selected-normal-background;
    text-color:       @selected-normal-foreground;
}
inputbar {
    spacing:          0px;
    text-color:       @normal-foreground;
    padding:          1px ;
    children:         [ prompt,textbox-prompt-colon,entry,case-indicator ];
}
case-indicator {
    spacing:          0;
    text-color:       @normal-foreground;
}
entry {
    spacing:          0;
    text-color:       @normal-foreground;
}
prompt {
    spacing:          0;
    text-color:       @normal-foreground;
}
textbox-prompt-colon {
    expand:           false;
    str:              ":";
    margin:           0px 0.3000em 0.0000em 0.0000em ;
    text-color:       inherit;
}
    ''))
  ];
in symlinkJoin {
  name = "custom-rofi";
  paths = [
    (writeShellScriptBin "rofi-launch" (mkRofi (commonFlags ++ [
      "-show" "combi"
      "-combi-modi"
      "drun"
    ])))

    (writeShellScriptBin "rofi-window" (mkRofi (commonFlags ++ [
      "-show" "combi"
      "-combi-modi"
      "window"
    ])))
    (writeShellScriptBin "dmenu" (mkRofi (commonFlags ++ [
      "-dmenu"
    ])))
  ];
}
