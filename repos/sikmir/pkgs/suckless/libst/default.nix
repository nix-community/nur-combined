{ lib, stdenv, fetchFromGitHub, ncurses }:

stdenv.mkDerivation rec {
  pname = "libst";
  version = "2021-06-06";

  src = fetchFromGitHub {
    owner = "jeremybobbin";
    repo = "libst";
    rev = "4bcd511e6dd0d88730b9359fd5a4d12781c2344a";
    hash = "sha256-vpU1Hbd6c/c0M/eUvQqW7RXHG2bz707LkcKlgFrzHtc=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "ar rcs" "\$(AR) rcs"
  '';

  nativeBuildInputs = [ ncurses ];

  buildInputs = [ ncurses ];

  postBuild = ''
    make -C examples/svt CFLAGS=-I$PWD LDFLAGS=-L$PWD
  '';

  preInstall = ''
    export HOME=$TMP
    mkdir -p $out/{lib,include}
  '';

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    make -C examples/svt install PREFIX=$out
  '';

  meta = with lib; {
    description = "Suckless Terminal ANSI parser";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
