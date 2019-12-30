{ stdenv, libpng, pkg-config, datamaps }:

stdenv.mkDerivation rec {
  pname = "datamaps";
  version = stdenv.lib.substring 0 7 src.rev;
  src = datamaps;

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
    description = datamaps.description;
    homepage = datamaps.homepage;
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
