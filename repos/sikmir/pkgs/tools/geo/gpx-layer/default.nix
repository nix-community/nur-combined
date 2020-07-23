{ stdenv, buildPerlPackage, shortenPerlShebang, XMLParser, sources }:
let
  pname = "gpx-layer";
  date = stdenv.lib.substring 0 10 sources.gpx-layer.date;
  version = "unstable-" + date;
in
buildPerlPackage {
  inherit pname version;
  src = sources.gpx-layer;

  outputs = [ "out" ];

  nativeBuildInputs = stdenv.lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = [ XMLParser ];

  preConfigure = "touch Makefile.PL";

  installPhase = ''
    install -Dm755 parse-gpx $out/bin/datamaps-parse-gpx
  '' + stdenv.lib.optionalString stdenv.isLinux ''
    patchShebangs $out/bin/datamaps-parse-gpx
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    shortenPerlShebang $out/bin/datamaps-parse-gpx
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpx-layer) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
