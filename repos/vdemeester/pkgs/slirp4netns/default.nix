{ stdenv, lib, fetchFromGitHub, automake, autoconf, gcc }:

stdenv.mkDerivation rec {
  name = "slirp4netns-${version}";
  version = "0.2.1";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "rootless-containers";
    repo = "slirp4netns";
    sha256 = "0kqncza4kgqkqiki569j7ym9pvp7879i6q2z0djvda9y0i6b80w4";
    inherit rev;
  };

  buildInputs = [
    automake autoconf gcc
  ];
  
  preConfigure = "./autogen.sh";
}
