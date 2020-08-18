{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nsc";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "0zlnc2ppzwdddsiiwjdsi32z8mdcsm9hphgwijyhg59a9f1ajh8b";
  };

  vendorSha256 = "071h1l52s6da2bl5s9hpjb7p0n2687sczz9z4j34lalx1qrwz77p";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Tool for creating nkey/jwt based configurations";
    homepage = "https://github.com/nats-io/nsc";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
