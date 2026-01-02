{
  fetchFromGitHub,
  lib,
  vte,
  xfce4-terminal,
}:

let
  vte-sixel = vte.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "GNOME";
      repo = "vte";
      rev = "f83883d4d3f2cbf73516e073a61d715a5d2aadd2";
      hash = "sha256-kc9tlqfQDYQTOgtIEJsUsjP9ZTRypDLhck5N6guL4us=";
    };

    patches = [ ];

    mesonFlags =
      (lib.filter (
        flag:
        # app option needs to be removed:
        # meson.build:17:0: ERROR: Unknown option: "app".
        !(lib.hasPrefix "-Dapp=" flag)
      ) old.mesonFlags)
      ++ [
        (lib.mesonBool "sixel" true)
      ];
  });
in
(xfce4-terminal.override {
  vte = vte-sixel;
}).overrideAttrs
  (old: {
    pname = "xfce4-terminal-sixel";
  })
