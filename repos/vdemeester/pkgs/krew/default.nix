{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "krew-${version}";
  version = "0.2.1";
  rev = "v${version}";

  goPackagePath = "github.com/GoogleContainerTools/krew";

  src = fetchFromGitHub {
    inherit rev;
    owner = "GoogleContainerTools";
    repo = "krew";
    sha256 = "078vc54mfgx0nigr0hwrih2i4ifq2kfk3jy4zj5i8hs7631xz5s1";
  };

  meta = {
    description = "The package manager for 'kubectl plugins. ";
    homepage = "https://github.com/GoogleContainerTools/krew";
    license = lib.licenses.asl20;
  };
}
