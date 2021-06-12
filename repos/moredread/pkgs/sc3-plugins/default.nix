# Adapted from a snipped by candeira
# https://www.snip2code.com/Snippet/4375157/Nix-package-definition-for-sc3-plugins/

{ stdenv, lib, fetchgit, cmake, supercollider, fftw, libsndfile }:
stdenv.mkDerivation rec {
	pname = "sc3-plugins";
	version = "3.11.0-rc2";

  src = fetchgit {
		url = "https://github.com/supercollider/sc3-plugins";
		rev = "Version-${version}";
		sha256 = "1rdmgdm2an1vlmm7rs5mia43p2mizjv04c61vvacl09nid1ixf0l";
		fetchSubmodules = true;
  };

  enableParallelBuilding = true;

	buildInputs = [ cmake supercollider fftw libsndfile ];
	cmakeFlags = [ "-DSUPERNOVA=OFF" "-DSC_PATH=${supercollider}/include/SuperCollider" "-DFFTW3F_LIBRARY=${fftw}/lib/"];
}



