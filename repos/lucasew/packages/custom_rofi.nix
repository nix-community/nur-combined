{ pkgs, ... }:
let
  commonFlags = "-theme gruvbox-dark -show-icons";
in
pkgs.symlinkJoin {
  name = "custom-rofi";
  paths = [
    (pkgs.writeShellScriptBin "my-rofi" ''
      ${pkgs.rofi}/bin/rofi -show combi -combi-modi window,drun ${commonFlags}
    '')
    (pkgs.writeShellScriptBin "dmenu" ''
      ${pkgs.rofi}/bin/rofi -dmenu ${commonFlags}
    '')
  ];
}

