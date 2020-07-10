{ lib, buildPerlPackage, XMLParser, sources }:
let
  pname = "gpx-layer";
  date = lib.substring 0 10 sources.gpx-layer.date;
  version = "unstable-" + date;
in
buildPerlPackage {
  inherit pname version;
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
