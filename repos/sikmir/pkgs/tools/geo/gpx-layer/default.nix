{ lib, buildPerlPackage, XMLParser, sources }:

buildPerlPackage {
  pname = "gpx-layer";
  version = lib.substring 0 7 sources.gpx-layer.rev;
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
    inherit (sources.gpx-layer) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
