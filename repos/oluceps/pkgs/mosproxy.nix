{ lib
, buildGo122Module
, fetchFromGitHub
}:
buildGo122Module {
  pname = "mosproxy";
  version = "unstable-2024-03-26";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "75dec96b4ca6faf238179c88a43fd6b452802cb4";
    hash = "sha256-8S0ynSHF1BK9NmMBVWeHMovHAlWrIHLSysCiL79hO18=";
  });
  vendorHash = "sha256-MGZkuhxEcxrswd68FiUl2uhnAVCT8OINXhuaG5Ds/dA=";
  doCheck = false;
  ldflags = [
    "-s"
    "-w"
  ];
  meta = with lib; {
    description = "A DNS proxy server";
    homepage = "https://github.com/IrineSistiana/mosproxy";
    license = licenses.gpl3;
  };
}
