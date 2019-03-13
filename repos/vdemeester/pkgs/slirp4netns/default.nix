{ stdenv, lib, fetchFromGitHub, automake, autoconf, gcc, glib, pkgconfig }:

stdenv.mkDerivation rec {
  name = "slirp4netns-${version}";
  version = "0.3.0-beta.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "rootless-containers";
    repo = "slirp4netns";
    sha256 = "0jdbkh0kp0yqsnslrr2pq84wmk3ishh44912cn155fmfp5p26cxf";
    inherit rev;
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    automake autoconf gcc glib
  ];

  preConfigure = "./autogen.sh";
}
