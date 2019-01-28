{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "prm-${version}";
  version = "2.4.1";
  rev = "v${version}";

  goPackagePath = "github.com/ldez/prm";

  buildFlagsArray = let t = "${goPackagePath}/meta"; in ''
    -ldflags=
       -X ${t}.Version=${version}
       -X ${t}.BuildDate=unknown
  '';

  src = fetchFromGitHub {
    inherit rev;
    owner = "ldez";
    repo = "prm";
    sha256 = "0r69yfrbfv56yqjcbf564sfcv61sbbiz9hs4pi02ac931zg60ysa";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
