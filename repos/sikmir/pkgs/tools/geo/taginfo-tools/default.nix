{ stdenv, fetchFromGitHub, cmake, bzip2, expat, gd, icu, libosmium, protozero, sqlite, zlib, sources }:

stdenv.mkDerivation {
  pname = "taginfo-tools";
  version = "unstable-2020-08-27";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = "taginfo-tools";
    rev = "794d5edc272efaaf5381e7ef513a630ddd4a13ec";
    sha256 = "05xcqrmm8hzhgbjlyiakzggqjnzbhkdz6qhr7m81mkz3gp0wxffp";
    fetchSubmodules = true;
  };

  cmakeFlags = stdenv.lib.optional stdenv.isDarwin "-DCMAKE_FIND_FRAMEWORK=LAST";

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
