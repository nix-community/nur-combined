{ pkgs, ... }:
let
  idlehandler = pkgs.writeShellScriptBin "sway-idlehandler" ''
    swayidle -w timeout 300 'swaylock --grace 70' before-sleep 'swaylock' timeout 360 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"'
  '';
in
{
  home.packages = with pkgs; [
    idlehandler
    swayidle
    swaylock-effects
  ];
}
