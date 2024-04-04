{
  lib,
  buildGo122Module,
  fetchFromGitHub,
}:
buildGo122Module {
  pname = "mosproxy";
  version = "0-unstable-2024-03-29";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "e194892ead6dbd56f5476fd93880474d1c153206";
    hash = "sha256-e+dn/12+GtUFD0kuU6Eb+sOc4d6IUeVm4MKMLbLDpts=";
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
