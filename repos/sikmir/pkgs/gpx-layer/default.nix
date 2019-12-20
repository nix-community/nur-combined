{ lib, buildPerlPackage, XMLParser, gpx-layer }:

buildPerlPackage rec {
  pname = "gpx-layer";
  version = lib.substring 0 7 src.rev;
  src = gpx-layer;

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
    description = gpx-layer.description;
    homepage = "https://github.com/ericfischer/gpx-layer";
    license = licenses.free;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
