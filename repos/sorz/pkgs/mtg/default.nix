{
  fetchFromGitHub,
  buildGoModule,
  lib,
}:

buildGoModule rec {
  pname = "mtg";
  version = "v2.1.7";
  src = fetchFromGitHub ({
    owner = "9seconds";
    repo = "mtg";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-7AJeiTyss/PlIMkTcCIwFrEmRIQYjleUXDUqjYfj/PM=";
  });
  vendorHash = "sha256-OCwJ0oBAHBoAyKTsacos4iZdOiX2iZ5XJBt6PopRxWo=";
  ldflags = [ "-X main.version=${version}" ];
  tags = [ "netgo" ];
  doCheck = false;

  meta = with lib; {
    description = "Highly opinionated MTPROTO proxy for Telegram";
    homepage = "https://github.com/9seconds/mtg";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "mtg";
  };
}
