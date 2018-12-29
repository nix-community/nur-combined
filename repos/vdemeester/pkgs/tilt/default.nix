{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "tilt-${version}";
  version = "0.4.0";
  rev = "v${version}";

  goPackagePath = "github.com/windmilleng/tilt";

  src = fetchFromGitHub {
    inherit rev;
    owner = "windmilleng";
    repo = "tilt";
    sha256 = "17zzkl6dym2p5xpws9j83kj2sylgdnw16nxligal2r29qwiw2116";
  };

  meta = {
    description = "Local Kubernetes development with no stress";
    homepage = "https://github.com/windmilleng/tilt";
    license = lib.licenses.asl20;
  };
}
