{ lib, stdenv, fetchFromGitHub, cmake, bzip2, expat, gd, icu, libosmium, protozero, sqlite, zlib, sources }:

stdenv.mkDerivation {
  pname = "taginfo-tools";
  version = "2020-11-17";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = "taginfo-tools";
    rev = "6b68c4208aef7994d34ef745350ee0ceda850ac2";
    sha256 = "0hk15k6lynq8yskpfrwh79686pfacdyb4jfab7x20m027p5rm3vs";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ bzip2 expat gd icu libosmium protozero sqlite zlib ];

  postInstall = ''
    install -Dm755 src/{osmstats,taginfo-sizes} -t $out/bin
  '';

  meta = with lib; {
    description = "C++ tools used in taginfo processing";
    homepage = "https://wiki.openstreetmap.org/wiki/Taginfo";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
