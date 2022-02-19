{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "hcl2json";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "tmccombs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-J4uV24SizvJ/hYz46EaNCLLciMScgVbeYQiv7/TRFAI=";
  };

  vendorSha256 = "sha256-VrrA9c/PWLyt4eH+hjZi1dxd9TP4/wU8xu+8y//thWA=";

  meta = with lib; {
    description = "Convert hcl2 to json";
    homepage = "https://github.com/tmccombs/hcl2json";
    license = with licenses; [ asl20 ];
    changelog = "https://github.com/tmccombs/hcl2json/blob/${version}/CHANGELOG.md";
  };
}
