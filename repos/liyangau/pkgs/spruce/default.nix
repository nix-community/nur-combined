{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "spruce";
  version = "1.30.1";

  src = fetchFromGitHub {
    owner = "geofffranks";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-yQ1meEqLCrcqUc9lmVnLqAgPI17VbkWgUV3onzlPF50=";
  };

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -extldflags '-static'"
    "-X main.Version=${version}"
  ];

  deleteVendor = true;
  vendorSha256 = "sha256-hRIuqOqx2Uncec1VwZ37x1TEx9E1akbe+41NZzFDeWM=";
  meta = with lib; {
    description = "A BOSH template merge tool";
    homepage = "https://github.com/geofffranks/spruce";
    license = licenses.mit;
  };
}