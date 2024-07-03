{ pkgs, ... }:
{
  home.packages = with pkgs; [ babashka ]; # For scripting
  programs.eww.configDir = ./.;
}
