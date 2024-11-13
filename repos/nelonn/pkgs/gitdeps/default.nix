{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "gitdeps";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Nelonn";
    repo = "gitdeps";
    rev = "v${version}";
    sha256 = "sha256-+jRduVLOU96TNkBkU+1KDrT2TtTTjU90Y36IjysDkpI=";
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
