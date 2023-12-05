{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "tg-bot-transmission";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "tg-bot-transmission";
    rev = "v${version}";
    sha256 = "sha256-HjIpi7yn/xGA+9tzHB+ejW6xCq6SGYN6DxdcB+PwGWo=";
  };

  vendorHash = "sha256-ZQ5iZwSU1CdQYOPgtrlU5+SElUvKelMjSe60TdhY3C8=";

  subPackages = ["cmd/bot"];

  ldflags = ["-X main.Version=${version}"];

  meta = with lib; {
    description = "Telegram bot for Transmission torrent client.";
    homepage = "https://github.com/pborzenkov/tg-bot-transmission";
    license = with licenses; [mit];
    maintainers = with maintainers; [pborzenkov];
  };
}
