{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mosdns";
  version = "5.3.1";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosdns";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-QujkDx899GAImEtQE28ru7H0Zym5SYXJbJEfSBkJYjo=";
  });
  vendorHash = "sha256-0J5hXb1W8UruNG0KFaJBOQwHl2XiWg794A6Ktgv+ObM=";
  doCheck = false;
  ldflags = [
    "-s"
    "-w"
  ];
  meta = with lib; {
    description = "A DNS proxy server";
    homepage = "https://github.com/IrineSistiana/mosdns";
    license = licenses.gpl3;
  };
}
