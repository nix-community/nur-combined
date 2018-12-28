{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "s2i-${version}";
  version = "1.1.13";
  rev = "v${version}";

  goPackagePath = "github.com/openshift/source-to-image";
  subPackages = [ "cmd/s2i" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "openshift";
    repo = "source-to-image";
    sha256 = "1xk749908jkshi6h7qid9pgx0gzmfdfs1dzgxb137lxxdav9fzqy";
  };

  meta = {
    description = "A tool for building/building artifacts from source and injecting into docker images";
    homepage = https://github.com/openshift/source-to-image;
    license = lib.licenses.asl20;
  };
}
