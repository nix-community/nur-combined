{ lib
, stdenv
, fetchurl
, iproute2
}:

stdenv.mkDerivation rec {
  pname = "parprouted";
  version = "0.7";

  src = fetchurl {
    url = "https://www.hazard.maks.net/parprouted/parprouted-${version}.tar.gz";
    sha256 = "sha256-1jZDyV1BSaPXERLaWJL0WUM0Vr8Ceb+jBGJfEJF43vw=";
  };

  patches = map fetchurl (import ./debian-patches.nix);

  postPatch = ''
    substituteInPlace parprouted.c --replace '/sbin/ip' '${iproute2}/bin/ip'
  '';

  installPhase = ''
    mkdir -p $out/share/man/man8 $out/bin
    install parprouted $out/bin
    install parprouted.8 $out/share/man/man8
  '';

  meta = with lib; {
    description = "Daemon for transparent IP proxy ARP bridging";
    homepage = "https://www.hazard.maks.net/parprouted/";
    license = licenses.gpl2;
  };
}
