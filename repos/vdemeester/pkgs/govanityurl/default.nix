{ stdenv, lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "govanityurl";
  name = "${pname}-${version}";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.sr.ht/~vdemeester/vanityurl";
    rev = "v${version}";
    sha256 = "05cj3760z3b7z6schp85hfmirfzwkgnx6big0b8j6d8wn9nls1zc";
  };
  vendorSha256 = "0s99bp9g1rfgrxmh9i94p2h8p68q93fk2799ifxd76r88f0f0hcn";
  modSha256 = "${vendorSha256}";
}
