{ lib, stdenv, fetchgit, cmake, expat, exiv2 }:

stdenv.mkDerivation {
  pname = "gpxtools";
  version = "2020-05-10";

  src = fetchgit {
    url = "https://notabug.org/irdvo/gpxtools.git";
    rev = "919fb5953af8de1e71f61244eb70dd56b670a429";
    sha256 = "sha256-GkrdvwzrxQs/hCghqBnALbRE8oSstNzckzpcLaGfCRs=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  postPatch = ''
    substituteInPlace gpxgeotag.cpp \
      --replace "exiv2" "${exiv2}/bin/exiv2"
  '';

  installPhase = "install -Dm755 gpx* -t $out/bin";

  meta = with lib; {
    description = "A collection of c++ tools for using GPX files";
    homepage = "https://notabug.org/irdvo/gpxtools";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/pull/127172
  };
}
