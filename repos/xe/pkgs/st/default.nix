{ pkgs ? import <nixpkgs> { } }:

pkgs.st.override rec {
  conf = pkgs.lib.readFile ./config.h;
  patches = [
    ./st-alpha-0.8.2.diff
    ./st-clipboard-0.8.2.diff
    ./st-bold-is-not-bright-20190127-3be4cf1.diff
    ./st-scrollback-0.8.2.diff
    ./st-scrollback-mouse-0.8.2.diff
    ./st-boxdraw_v2-0.8.2.diff
    ./st-anysize-0.8.1.diff
  ];
}
