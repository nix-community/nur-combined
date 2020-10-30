{ stdenv, fetchFromGitHub, cmake, bzip2, expat, gd, icu, libosmium, protozero, sqlite, zlib, sources }:

stdenv.mkDerivation {
  pname = "taginfo-tools";
  version = "unstable-2020-10-28";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = "taginfo-tools";
    rev = "088602ac10d8707d94589c4a0b9d6eff48edf9f2";
    sha256 = "0yx4bh2gmxsmk8jz8qsxv73h3hi5v3hcpzlaaszjixc88aqa3zz3";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ bzip2 expat gd icu libosmium protozero sqlite zlib ];

  postInstall = ''
    install -Dm755 src/{osmstats,taginfo-sizes} -t $out/bin
  '';

  meta = with stdenv.lib; {
    description = "C++ tools used in taginfo processing";
    homepage = "https://wiki.openstreetmap.org/wiki/Taginfo";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
