{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "prm-${version}";
  version = "2.6.1";
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
    sha256 = "02r0cc8nacp9mhnjbrg495p92g1pzxs2b7b2dgsclx00mfd1qpn5";
  };
  modSha256 = "0qrgq1453ngkwshyyihj5dz6hdwr0k2alz3s2qpj0qic9n7zx7sn";

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
