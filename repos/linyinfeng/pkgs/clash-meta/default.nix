{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

buildGoModule rec {
  pname = "clash-meta";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "Clash.Meta";
    rev = "v${version}";
    sha256 = "sha256-xlrhDCvRWvDz6TsHj04x0ojTfL+gkhHLLy9VnJkETqI=";
  };

  vendorSha256 = "sha256-8cbcE9gKJjU14DNTLPc6nneEPZg7Akt+FlSDlPRvG5k=";

  doCheck = false;
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Dreamacro/clash/constant.Version=${version}"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    homepage = "https://github.com/MetaCubeX/Clash.Meta";
    description = "A rule-based tunnel in Go";
    changelog = "https://github.com/MetaCubeX/Clash.Meta/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
