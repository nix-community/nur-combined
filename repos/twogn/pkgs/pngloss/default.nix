{ stdenv, fetchgit, cmake, lib, pkgs }:
stdenv.mkDerivation rec {
  name = "pngloss";
  src = fetchgit {
    url = "https://github.com/foobaz/pngloss.git";
    rev = "559f09437e1c797a1eaf08dfdcddd9b082f0e09c";
    sha256 = "sha256-dqrrzbLu4znyWOlTDIf56O3efxszetiP+CdFiy2PBd4=";
  };
  buildInputs = with pkgs;[
    libpng
    pkg-config
    zlib
  ];
  builder = ./builder.sh;
  
  meta = with lib;{
    description = "Lossy compression of PNG images";
    homepage = "https://github.com/foobaz/pngloss";
    license = licenses.mit;
    platforms = platforms.all;
  };
}