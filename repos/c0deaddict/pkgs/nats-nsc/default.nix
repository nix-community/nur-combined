{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nsc";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "sha256-uONwonKxVwKwX+boBg8DCDB9qIJpiV348BRD8VBzQ2Q=";
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
