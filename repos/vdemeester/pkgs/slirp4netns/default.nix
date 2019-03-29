{ stdenv, lib, fetchFromGitHub, automake, autoconf, gcc, glib, pkgconfig }:

stdenv.mkDerivation rec {
  name = "slirp4netns-${version}";
  version = "0.3.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "rootless-containers";
    repo = "slirp4netns";
    sha256 = "079m44l4l0p1c2sbkpzsy6zpv94glwmrc72ip2djcscnaq4b1763";
    inherit rev;
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    automake autoconf gcc glib
  ];

  preConfigure = "./autogen.sh";
}
