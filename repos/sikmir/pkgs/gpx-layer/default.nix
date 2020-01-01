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
    homepage = gpx-layer.homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
