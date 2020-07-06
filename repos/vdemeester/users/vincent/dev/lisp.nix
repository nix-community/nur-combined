{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sbcl
    asdf
  ];
}
