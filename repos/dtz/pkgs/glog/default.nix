{ stdenv, fetchFromGitHub, autoreconfHook, cmake, useCMake ? false }:

stdenv.mkDerivation rec {
  name = "glog-${version}";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "google";
    repo = "glog";
    rev = "v${version}";
    sha256 = "12v7j6xy0ghya6a0f6ciy4fnbdc486vml2g07j9zm8y5xc6vx3pq";
  };

  nativeBuildInputs = [ (if useCMake then cmake else autoreconfHook) ];

  meta = with stdenv.lib; {
    homepage = https://github.com/google/glog;
    license = licenses.bsd3;
    description = "Library for application-level logging";
    platforms = platforms.unix;
  };
}
