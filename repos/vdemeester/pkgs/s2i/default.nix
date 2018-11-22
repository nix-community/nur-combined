{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "s2i-${version}";
  version = "1.1.12";
  rev = "v${version}";

  goPackagePath = "github.com/openshift/source-to-image";
  subPackages = [ "cmd/s2i" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "openshift";
    repo = "source-to-image";
    sha256 = "1f7k1z1sgn5dd45ww29fyidz06a60mrvm38dzd8ndwblwbz6z11f";
  };

  meta = {
    description = "A tool for building/building artifacts from source and injecting into docker images";
    homepage = https://github.com/openshift/source-to-image;
    license = lib.licenses.asl20;
  };
}
