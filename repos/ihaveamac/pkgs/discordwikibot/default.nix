{ fetchFromGitHub, buildDotnetModule , lib}:

buildDotnetModule rec {
  pname = "discordwikibot";
  version = "2024-07-01";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = "DiscordWikiBot";
    rev = "00bb021a89e522c5afbeb4349b6368ad83577a09";
    hash = "sha256-bsX7GKhuTWIU7EjEblw1/8V7FQ7RC7mIcUyB8mreewY=";
  };

  projectFile = "DiscordWikiBot/DiscordWikiBot.csproj";
  nugetDeps = ./deps.nix;

  meta = with lib; {
    description = "Discord bot for Wikimedia projects and MediaWiki wiki sites";
    homepage = "https://github.com/stjohann/DiscordWikiBot";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "DiscordWikiBot";
  };
}
