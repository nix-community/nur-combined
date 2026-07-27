{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "prm-${version}";
  version = "3.4.5";
  rev = "v${version}";

  ldflags =
    let t = "github.com/ldez/prm/v3/meta";
    in
    [
      "-X ${t}.Version=${version}"
      "-X ${t}.BuildDate=unknown"
    ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "ldez";
    repo = "prm";
    sha256 = "sha256-ZrzZ4aJ9uB7iFHLCDsTJp8POqOG2HhrIC2cYg31tYdg=";
  };
  vendorHash = "1k1n2ylxrbkdwli0nh56fv7q8c7yl0661ayvpgirlp19704za509";

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = https://github.com/ldez/prm;
    license = lib.licenses.asl20;
  };
}
