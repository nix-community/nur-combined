{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "govanityurl";
  name = "${pname}-${version}";
  version = "unstable-2020-02-18";
  rev = "7d96c4d8e4390c625bf358526e7281f84f79b83a";

  goPackagePath = "github.com/gotestyourself/vanityurl";
  src = fetchFromGitHub {
    inherit rev;
    owner = "gotestyourself";
    repo = "vanityurl";
    sha256 = "02ba1wxjs1nl9cibhlhhp8fp6vv1zj7nb2zha38sgb4f0bgacd2p";
  };
  modSha256 = "0s99bp9g1rfgrxmh9i94p2h8p68q93fk2799ifxd76r88f0f0hcn";
}
