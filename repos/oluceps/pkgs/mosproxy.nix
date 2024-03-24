{ lib
, buildGo122Module
, fetchFromGitHub
}:
buildGo122Module {
  pname = "mosproxy";
  version = "unstable-2024-03-23";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "20d5587848e64bc037699fd54afef971d67ac0d4";
    hash = "sha256-new6sT8uXx9snWv0DU0LlWsUKl0yN5TPNGq3fNzP9rs=";
  });
  vendorHash = "sha256-cTKjJ/NmEHElBuagzYOozjrbP2hSHDfUrizdCilP41U=";
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
