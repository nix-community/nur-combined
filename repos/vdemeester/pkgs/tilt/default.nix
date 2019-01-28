{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "tilt-${version}";
  version = "0.5.1";
  rev = "v${version}";

  goPackagePath = "github.com/windmilleng/tilt";

  src = fetchFromGitHub {
    inherit rev;
    owner = "windmilleng";
    repo = "tilt";
    sha256 = "0zdgp7s1s4pas16jzcbc84w31wdjyxzm9cdypqiswh6ib4jhd7rs";
  };

  meta = {
    description = "Local Kubernetes development with no stress";
    homepage = "https://github.com/windmilleng/tilt";
    license = lib.licenses.asl20;
  };
}
