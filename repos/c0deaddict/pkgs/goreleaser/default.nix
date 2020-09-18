{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goreleaser";
  version = "0.143.0";

  src = fetchFromGitHub {
    owner = "goreleaser";
    repo = pname;
    rev = "v${version}";
    sha256 = "104rlw8zn0qhkr62wlrwlj13d0lhqlbh521ayfm80y8raqmrbwdl";
  };

  vendorSha256 = "1vin019wkz4j0lmg420crsis8vir74xfixlnzk8n8i10fwhk5wdc";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  doCheck = false;

  meta = with lib; {
    description = "Deliver Go binaries as fast and easily as possible";
    homepage = "https://goreleaser.com";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.mit;
  };
}
