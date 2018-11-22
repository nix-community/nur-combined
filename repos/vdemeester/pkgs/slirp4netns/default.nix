{ stdenv, lib, fetchFromGitHub, automake, autoconf, gcc }:

stdenv.mkDerivation rec {
  name = "slirp4netns-${version}";
  version = "unstable-2018-11-01";
  rev = "01f874a15ba08878b72a8bf8ddb8b9817f9dc1d9";

  src = fetchFromGitHub {
    owner = "rootless-containers";
    repo = "slirp4netns";
    sha256 = "1czwkqavrzmknyc9qzr8ck6hmdjpks3zb2wy5i2hxzhrjs8g0m83";
    inherit rev;
  };

  buildInputs = [
    automake autoconf gcc
  ];
  
  preConfigure = "./autogen.sh";
}
