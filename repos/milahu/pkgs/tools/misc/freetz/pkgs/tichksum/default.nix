{ lib
, stdenv
, fetchFromGitHub
, freetz
}:

stdenv.mkDerivation rec {
  pname = "tichksum";
  inherit (freetz) version;

  src = freetz.src + "/make/host-tools/tichksum-host/src";

  installPhase = ''
    mkdir -p $out/bin
    cp tichksum $out/bin
  '';

  meta = with lib; {
    description = "add, verify and remove checksums";
    inherit (freetz.meta) homepage license;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
