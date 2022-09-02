{ lib, stdenv, fetchFromGitHub, pkg-config, ncurses, w3m, ueberzug }:

stdenv.mkDerivation rec {
  pname = "cfiles";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "mananapr";
    repo = "cfiles";
    rev = "v${version}";
    hash = "sha256-Y5OOA0GGnjl4614zicuS00Wz2x5lLzhEHVioNFADQto=";
  };

  postPatch = ''
    substituteInPlace scripts/clearimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg_uberzug \
      --replace "ueberzug" "${ueberzug}/bin/ueberzug"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses w3m ueberzug ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "A ncurses file manager written in C with vim like keybindings";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
