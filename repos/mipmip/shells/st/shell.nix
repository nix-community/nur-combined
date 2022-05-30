with (import <nixpkgs> {});
mkShell {
  nativeBuildInputs = [
    pkg-config
    ncurses
    fontconfig
    xorg.libX11
    xorg.libXft
    freetype
  ];
}
