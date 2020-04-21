{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "govanityurl";
  name = "${pname}-${version}";
  version = "unstable-2020-04-21";
  rev = "dc69709ad3d951c32263b4e43029d54e818e7d2b";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "vanityurl";
    sha256 = "0birf5y8j9s7s2ycqdx1rl0qivb93bkya4y25yigjyiclcgqp8a4";
  };
  modSha256 = "0s99bp9g1rfgrxmh9i94p2h8p68q93fk2799ifxd76r88f0f0hcn";
}
