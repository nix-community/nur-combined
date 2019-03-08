{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "tilt-${version}";
  version = "0.7.6";
  rev = "v${version}";

  goPackagePath = "github.com/windmilleng/tilt";

  src = fetchFromGitHub {
    inherit rev;
    owner = "windmilleng";
    repo = "tilt";
    sha256 = "10y379ma3x9msyylj3r3w1is94maf7v4zv478jcrj4lp6aililjc";
  };

  meta = {
    description = "Local Kubernetes development with no stress";
    homepage = "https://github.com/windmilleng/tilt";
    license = lib.licenses.asl20;
  };
}
