{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nsc";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "0dr9vfbf5mn4ddxnbc68ixvrr5dzp7pjhp7m9agngb9zp1n9m8zk";
  };

  vendorSha256 = null;
  modSha256 = vendorSha256;

  doCheck = false;

  meta = with lib; {
    description = "Tool for creating nkey/jwt based configurations";
    homepage = "https://github.com/nats-io/nsc";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
