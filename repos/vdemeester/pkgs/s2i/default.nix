{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "s2i-${version}";
  version = "1.1.14";
  rev = "v${version}";

  goPackagePath = "github.com/openshift/source-to-image";
  subPackages = [ "cmd/s2i" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "openshift";
    repo = "source-to-image";
    sha256 = "05cjbp694ds35wwj5jaw2804lb68dp1mdjrgj9dkgf84swbgn0yg";
  };

  meta = {
    description = "A tool for building/building artifacts from source and injecting into docker images";
    homepage = https://github.com/openshift/source-to-image;
    license = lib.licenses.asl20;
  };
}
