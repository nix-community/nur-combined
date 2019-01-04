{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "prm-${version}";
  version = "2.3.0";
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
    sha256 = "1kcd249q5bdmxgssvmd6jxx18fy0dg61w1m017l92fj2m02g5j8b";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
