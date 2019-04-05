{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "esc-${version}";
  version = "0.2.0";

  goPackagePath = "github.com/mjibson/esc";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "mjibson";
    repo = "esc";
    sha256 = "0ci3bdm01prm114plcwkgzbqn825lh0zc1iqaw3jicjay5sh0bis";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "A simple file embedder for Go";
    homepage = "https://github.com/mjibson/esc";
    license = lib.licenses.asl20;
  };
}
