{ pkgs, ... }:

{
  home.packages = with pkgs; [ next ];
}
