{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tg-bot-skyeng";
  version = "2021-04-08-645c17d";

  src = fetchFromGitHub {
    owner = "pachmu";
    repo = "skyeng-push-notificator";
    rev = "645c17d2cfc979adca3673ed07a26a6b9631690d";
    sha256 = "0684qxvc3izi60ly5rbxasl24cfxpx3lqx8p7bwwly95n8mc960c";
  };

  vendorSha256 = "1893j1v6qvflmx3qlbn8kikwypphr612r9p5f1y1d27x4m85by8f";

  subPackages = [ "cmd" ];

  meta = with lib; {
    description = "Telegram bot for Skyeng word lists.";
    homepage = "https://github.com/pachmu/skyeng-push-notificator";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
