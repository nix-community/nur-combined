{ lib, stdenv, libX11, libXinerama, libXft, zlib, patches ? null, fetchFromGitLab }:

stdenv.mkDerivation rec {
  name = "dmenu-5.0";

  src = fetchFromGitLab {
    owner = "ethancedwards";
    repo = "dmenu-config";
    rev = "9cd6fe49998b48aa1b97e8b66d8895624b0ac897";
    sha256 = "Kqhf7+kl+izCyrcwW6LaNrbYFh23j1nmBN+7/ebOlA0=";
  };

  buildInputs = [ libX11 libXinerama zlib libXft ];

  inherit patches;

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  makeFlags = [ "CC:=$(CC)" ];

  meta = with lib; {
      description = "A generic, highly customizable, and efficient menu for the X Window System";
      homepage = "https://tools.suckless.org/dmenu";
      license = licenses.mit;
      maintainers = with maintainers; [ pSub globin ];
      platforms = platforms.all;
  };
}
