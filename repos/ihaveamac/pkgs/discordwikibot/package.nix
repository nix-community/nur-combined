{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
}:

buildDotnetModule rec {
  pname = "DiscordWikiBot";
  version = "0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = pname;
    rev = "8a92a956e9781947b546125ae57ba3035093f07c";
    hash = "sha256-9ePrXdOzmwz4kTbFiJFT8VxnE6bMr2eimWJLDqgT4jw=";
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
