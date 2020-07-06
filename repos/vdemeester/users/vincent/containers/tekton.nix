{ pkgs, ... }:

{
  home.packages = with pkgs; [
    my.tkn
  ];
}
