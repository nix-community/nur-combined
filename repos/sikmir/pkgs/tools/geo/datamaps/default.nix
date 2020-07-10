{ stdenv, libpng, pkg-config, sources }:
let
  pname = "datamaps";
  date = stdenv.lib.substring 0 10 sources.datamaps.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.datamaps;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libpng ];

  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  installPhase = ''
    for tool in encode enumerate merge render; do
      install -Dm755 $tool $out/bin/$pname-$tool
    done
  '';

  meta = with stdenv.lib; {
    inherit (sources.datamaps) description homepage;
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
