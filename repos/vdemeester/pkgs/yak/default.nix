{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "yak-${version}";
  version = "0.0.1";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/yak";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "yak";
    sha256 = "1zyw3ba2kn547f38inv3h3i2574l2qny3zll0njfjfvrakqbvvgc";
  };

  meta = {
    description = "yak — Yet Another Kubernetes …";
    homepage = "https://github.com/vdemeester/yak";
    license = lib.licenses.asl20;
  };
}
