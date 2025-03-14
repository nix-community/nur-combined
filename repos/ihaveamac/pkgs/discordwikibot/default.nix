{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
}:

buildDotnetModule rec {
  pname = "discordwikibot";
  version = "0-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = "DiscordWikiBot";
    rev = "cd1da3c974a36579b6658f0174ac5af6caec750d";
    hash = "sha256-GGuKySuEFplypoSR6gKUgy5M7FuT8B+GKUmYX487Uxg=";
  };

  projectFile = "DiscordWikiBot/DiscordWikiBot.csproj";
  nugetDeps = ./deps.json;

  meta = with lib; {
    description = "Discord bot for Wikimedia projects and MediaWiki wiki sites";
    homepage = "https://github.com/stjohann/DiscordWikiBot";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "DiscordWikiBot";
  };
}
