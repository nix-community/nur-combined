{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "prm-${version}";
  version = "2.5.1";
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
    sha256 = "00qrh2xa5dqfcapsv3xmys6vg2gflqkwjvr3mn0m762zr95dg1b1";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
