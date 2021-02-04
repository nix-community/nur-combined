{ lib, stdenv, libpng, pkg-config, sources }:

stdenv.mkDerivation {
  pname = "datamaps";
  version = lib.substring 0 10 sources.datamaps.date;

  src = sources.datamaps;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libpng ];

  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  installPhase = ''
    for tool in encode enumerate merge render; do
      install -Dm755 $tool $out/bin/datamaps-$tool
    done
  '';

  meta = with lib; {
    inherit (sources.datamaps) description homepage;
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
