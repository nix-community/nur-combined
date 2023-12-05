{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule {
  pname = "tg-bot-skyeng";
  version = "2021-04-08-645c17d";

  src = fetchFromGitHub {
    owner = "pachmu";
    repo = "skyeng-push-notificator";
    rev = "645c17d2cfc979adca3673ed07a26a6b9631690d";
    sha256 = "sha256-DJjEKrIlecr5Ohd1TEe/3TEiqFZ95eIpMPHHwXbHBBk=";
  };

  vendorHash = "sha256-DvlVUCX9iBZ8cOWmLILJ8F7PZ5zILopHr9RtbHaQI6E=";

  subPackages = ["cmd"];

  meta = with lib; {
    description = "Telegram bot for Skyeng word lists.";
    homepage = "https://github.com/pachmu/skyeng-push-notificator";
    license = with licenses; [mit];
    maintainers = with maintainers; [pborzenkov];
  };
}
