{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nsc";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "0lbgivrpibz5kbiy658hbp6jpfcqp96gahc56gwsj7ff67y4a10i";
  };

  vendorSha256 = null;
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Tool for creating nkey/jwt based configurations";
    homepage = "https://github.com/nats-io/nsc";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
