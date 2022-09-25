{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "snid";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "AGWA";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-A0+X407zYp+XiwOSFljIJ0S7dZqQViAhJn6tZJQYxlM=";
  };

  vendorSha256 = "sha256-69H57AzzAmvLQarg7cli6FiGarVE79j/leq8bPnn92g=";

  meta = with lib; {
    description = "Zero config SNI proxy server";
    homepage = "https://github.com/AGWA/snid";
    license = licenses.mit;
  };
}
