{ lib
, stdenv
, fetchFromGitHub
, freetz
}:

stdenv.mkDerivation rec {
  pname = "find-squashfs";
  inherit (freetz) version;

  src = freetz.src + "/make/host-tools/find-squashfs-host/src";

  installPhase = ''
    mkdir -p $out/bin
    cp find-squashfs $out/bin
  '';

  meta = with lib; {
    description = "";
    inherit (freetz.meta) homepage license;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
