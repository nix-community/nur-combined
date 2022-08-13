{ writeShellScriptBin
, symlinkJoin
, rofi
}:
let
    commonFlags = "-theme gruvbox-dark -show-icons";
  in symlinkJoin {
    name = "custom-rofi";
    paths = [
      (writeShellScriptBin "rofi-launch" ''
        ${rofi}/bin/rofi -show combi -combi-modi drun ${commonFlags}
      '')
      (writeShellScriptBin "rofi-window" ''
        ${rofi}/bin/rofi -show combi -combi-modi window ${commonFlags}
      '')
      (writeShellScriptBin "dmenu" ''
        ${rofi}/bin/rofi -dmenu ${commonFlags}
      '')
    ];
  }


