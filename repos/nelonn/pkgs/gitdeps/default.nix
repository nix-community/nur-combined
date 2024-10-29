{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "gitdeps";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "Nelonn";
    repo = "gitdeps";
    rev = "v${version}";
    sha256 = "sha256-VE3hNpJLmncESktjWiyFOpAY2gnMsgVwIWBhnLL4ujc=";
  };
  vendorHash = null;

  ldflags = [
    "-s -w -X main.Version=${version}"
  ];

  CGO_ENABLED = 0;
  
  meta = with lib; {
    description = "Git dependencies manager. Simplified version of git submodules.";
    homepage = "https://github.com/Nelonn/gitdeps";
    license = with licenses; [ mit ];
  };
}
