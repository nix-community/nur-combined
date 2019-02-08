{ stdenv, fetchFromGitHub, autoconf, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "slirp4netns-${version}";
  version = "0.3.0-alpha.2";

  src = fetchFromGitHub {
    owner = "rootless-containers";
    repo = "slirp4netns";
    rev = "v${version}";
    sha256 = "163nwdwi1qigma1c5svm8llgd8pn4sbkchw67ry3v0gfxa9mxibk";
  };

  nativeBuildInputs = [ autoreconfHook ];
}
