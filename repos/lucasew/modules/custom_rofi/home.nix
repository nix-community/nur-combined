{ config, pkgs, ... }:
let
  rofiScript = pkgs.writeShellScriptBin "my-rofi" ''
    ${pkgs.rofi}/bin/rofi -show combi -combi-modi window,drun -theme gruvbox-dark -show-icons
  '';
in
{
  home.packages = [
    rofiScript
  ];
}
