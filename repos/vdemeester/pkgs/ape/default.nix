{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ape-${version}";
  version = "0.3.0";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ape";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ape";
    sha256 = "17zhcaxkqn752hjxh8nlpmryaw2n0wp8fjg8pp0dsv3k0ym7wcx0";
  };

  meta = {
    description = "a git mirror *upstream* updater ";
    homepage = "https://github.com/vdemeester/ape";
    license = lib.licenses.asl20;
  };
}
