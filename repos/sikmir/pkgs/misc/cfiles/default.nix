{ lib, stdenv, fetchFromGitHub, pkg-config, ncurses, w3m, ueberzug }:

stdenv.mkDerivation rec {
  pname = "cfiles";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "mananapr";
    repo = "cfiles";
    rev = "v${version}";
    sha256 = "1nj20d839a2q3m23hbv53vdv6ifkjb5qjcsyxdw3k7l6841qx4v3";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses w3m ueberzug ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "" \
      --replace "prefix = usr" "prefix=$out"
    substituteInPlace scripts/clearimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg_uberzug \
      --replace "ueberzug" "${ueberzug}/bin/ueberzug"
  '';

  meta = with lib; {
    description = "A ncurses file manager written in C with vim like keybindings";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
