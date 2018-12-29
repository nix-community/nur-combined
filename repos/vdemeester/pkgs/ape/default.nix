{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ape-${version}";
  version = "0.2.0";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ape";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ape";
    sha256 = "0y7dapmsacs0hm5j79n3xfs2a53bsqb0fkjhg9ki87hb7nzszrfl";
  };

  meta = {
    description = "a git mirror *upstream* updater ";
    homepage = "https://github.com/vdemeester/ape";
    license = lib.licenses.asl20;
  };
}
