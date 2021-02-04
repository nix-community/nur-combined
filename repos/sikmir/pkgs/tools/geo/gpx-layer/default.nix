{ lib, stdenv, buildPerlPackage, shortenPerlShebang, XMLParser, sources }:

buildPerlPackage {
  pname = "gpx-layer";
  version = lib.substring 0 10 sources.gpx-layer.date;

  src = sources.gpx-layer;

  outputs = [ "out" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = [ XMLParser ];

  preConfigure = "touch Makefile.PL";

  installPhase = ''
    install -Dm755 parse-gpx $out/bin/datamaps-parse-gpx
  '' + lib.optionalString stdenv.isLinux ''
    patchShebangs $out/bin/datamaps-parse-gpx
  '' + lib.optionalString stdenv.isDarwin ''
    shortenPerlShebang $out/bin/datamaps-parse-gpx
  '';

  meta = with lib; {
    inherit (sources.gpx-layer) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
