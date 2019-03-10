{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "tilt-${version}";
  version = "0.7.7";
  rev = "v${version}";

  goPackagePath = "github.com/windmilleng/tilt";

  src = fetchFromGitHub {
    inherit rev;
    owner = "windmilleng";
    repo = "tilt";
    sha256 = "0s5w2xpq7v9ms92gf98jv48jjmjd3854kp2zmkvg5kx1ssndfscv";
  };

  meta = {
    description = "Local Kubernetes development with no stress";
    homepage = "https://github.com/windmilleng/tilt";
    license = lib.licenses.asl20;
  };
}
