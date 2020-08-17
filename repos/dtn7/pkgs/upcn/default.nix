{ stdenv, fetchFromGitHub, fetchurl, tinycbor }:

stdenv.mkDerivation rec {
  pname = "upcn";
  version = "0.7.0";

  src = fetchurl {
    url = "https://upcn.eu/releases/upcn-${version}.tar.gz";
    sha256 = "1lib4q8z3s2d1mzihh0xlkqrxas738kwq3v0sly09ca6p84bn83l";
  };
  sourceRoot = ".";

  postUnpack = "cp -r ${tinycbor.src}/* external/tinycbor";

  installPhase = "cp build/posix/upcn $out";

  meta = with stdenv.lib; {
    description = "Micro Planetary Communication Network is an implementation of Delay-tolerant Networking protocols";
    homepage = "https://upcn.eu/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ oxzi ];
  };
}
