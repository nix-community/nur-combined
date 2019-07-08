{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "prm-${version}";
  version = "2.6.0";
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
    sha256 = "0jgy16dc7np9ij7zv769zazsa59vh1ipsiyvy6c4376yv2m10zm0";
  };
  modSha256 = "00m0j0a0k0ckx1v592vigqrlclnvnm66lq40i2i9xqg5yp0235yq";

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
