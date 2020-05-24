{ pkgs ? import <nixpkgs> { } }:

pkgs.dwm.overrideAttrs (old: rec {
  postPatch = ''
    cp ${./config.h} ./config.h
  '';

  patches = [
    ./alphasystray.diff
    ./dwm-uselessgap-6.2.diff
    ./dwm-autostart-20161205-bb3bd6f.diff
    ./dwm-pertag-6.2.diff
    ./dwm-centeredmaster-6.1.diff
    ./dwm-attachbelow-6.2.diff
    ./dwm-cfacts-6.2.diff
  ];
})
