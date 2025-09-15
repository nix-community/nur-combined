{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
}:

stdenv.mkDerivation rec {
  pname = "ninvaders-workman";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "Oliper202020";
    repo = "ninvaders-workman";
    rev = "v${version}";
    sha256 = "sha256-D73T33HdKwE9Wk2mvuSazx8jkV0BaIJJ4UUzZHT1ErM=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ncurses ];

  meta = with lib; {
    description = "Space Invaders clone based on ncurses";
    mainProgram = "ninvaders";
    homepage = "https://ninvaders.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ _1000101 ];
    platforms = platforms.all;
  };
}
