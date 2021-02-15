{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "natscli";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "1k961y4hpy82s3nyyhn6y2ccyf9f3blxpri652v8am8m7vbf8kyy";
  };

  vendorSha256 = "12159gykphf26nnlsi6r8ash8b7i56pzlarmcxgwq5b1skyz7b76";
  modSha256 = vendorSha256;

  doCheck = false;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "The NATS Command Line Interface";
    homepage = "https://github.com/nats-io/natscli";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
