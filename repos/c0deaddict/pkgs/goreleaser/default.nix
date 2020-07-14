{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goreleaser";
  version = "0.140.0";

  src = fetchFromGitHub {
    owner = "goreleaser";
    repo = pname;
    rev = "v${version}";
    sha256 = "1l3z6a4i5rcf8snlrilx4q2dr5q14vd38r7g29f1sam6s7640sfi";
  };

  vendorSha256 = "1gacg7gnsr0h08fz302zq4nkgg8ka4gxh12g5b0x2csqp7dn73j1";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Deliver Go binaries as fast and easily as possible";
    homepage = "https://goreleaser.com";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.mit;
  };
}
