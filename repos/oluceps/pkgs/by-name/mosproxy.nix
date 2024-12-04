{
  lib,
  buildGo122Module,
  fetchFromGitHub,
}:
buildGo122Module {
  pname = "mosproxy";
  version = "0-unstable-2024-06-11";
  src = fetchFromGitHub {
    owner = "IrineSistiana";
    repo = "mosproxy";
    rev = "ed14b30c83fc3200263268c9724a1e01715a880b";
    hash = "sha256-jL0arbQv5zkk9jyhINGSiCN1AwYDZUf2iYPnQAceKpI=";
  };
  vendorHash = "sha256-Ut1f7CMPKP5dt4KpZC2m4pKwwUZdZvxHQHNx3qgPpto=";
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
