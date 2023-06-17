{
  stdenv,
  fetchzip,
  lib,
  autoPatchelfHook,
  gcc,
  glibc
}:

stdenv.mkDerivation rec {
  pname = "pwn-adventure3";
  version = "3";

  src = fetchzip  {
    url = "http://www.pwnadventure.com/PwnAdventure${version}_Linux.zip";
    sha256 = "19h5kl3ymn0sgzx742pxy5binqfy86xbf6pxri7m5i7k5swhlzl4";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    gcc
    glibc
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/
    cp -r ./source/* $out/
  '';

  meta = with lib; {
    homepage = "http://www.pwnadventure.com/";
    description = "PwnAdventure3";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ "Franciszek Łopuszański<franopusz2006@gmail.com>" ];
  };
}