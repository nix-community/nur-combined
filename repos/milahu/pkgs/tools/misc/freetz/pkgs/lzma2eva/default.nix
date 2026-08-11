{ lib
, stdenv
, fetchFromGitHub
, freetz
, zlib
}:

stdenv.mkDerivation rec {
  pname = "lzma2eva";
  inherit (freetz) version;

  src = freetz.src + "/make/host-tools/lzma2eva-host/src";

  buildInputs = [
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $(grep '^all:' Makefile | cut -c5-) $out/bin
  '';

  meta = with lib; {
    description = "convert lzma-compressed file to AVM EVA bootloader format";
    inherit (freetz.meta) homepage;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
    license = licenses.mit;
  };
}
