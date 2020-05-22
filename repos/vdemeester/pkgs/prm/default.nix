{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "prm-${version}";
  version = "3.3.0";
  rev = "v${version}";

  goPackagePath = "github.com/ldez/prm";

  buildFlagsArray = let t = "${goPackagePath}/meta"; in
    ''
      -ldflags=
         -X ${t}.Version=${version}
         -X ${t}.BuildDate=unknown
    '';

  src = fetchFromGitHub {
    inherit rev;
    owner = "ldez";
    repo = "prm";
    sha256 = "0biqr091yxpmq6z2pw6xnzilqa3cbkryj4rc7gqc7dvp24farr1h";
  };
  modSha256 = "1vdq07ml5s5anbkybwx08s1j3dssv4c1pdkp8dcbarlp07d5y7n1";

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
