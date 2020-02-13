{ lib, buildPerlPackage, XMLParser, sources }:

buildPerlPackage rec {
  pname = "gpx-layer";
  version = lib.substring 0 7 src.rev;
  src = sources.gpx-layer;

  outputs = [ "out" ];

  propagatedBuildInputs = [ XMLParser ];

  preConfigure = ''
    patchShebangs .
    touch Makefile.PL
  '';

  installPhase = ''
    install -Dm755 parse-gpx $out/bin/datamaps-parse-gpx
  '';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
