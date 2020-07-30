{ stdenv, cmake, bzip2, expat, gd, icu, libosmium, protozero, sparsehash, sqlite, zlib, sources }:
let
  pname = "taginfo-tools";
  date = stdenv.lib.substring 0 10 sources.taginfo-tools.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.taginfo-tools;

  cmakeFlags = stdenv.lib.optional stdenv.isDarwin "-DCMAKE_FIND_FRAMEWORK=LAST";

  nativeBuildInputs = [ cmake ];
  buildInputs = [ bzip2 expat gd icu libosmium protozero sparsehash sqlite zlib ];

  postInstall = ''
    install -Dm755 src/{osmstats,taginfo-sizes} -t $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (sources.taginfo-tools) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
