{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
}:

buildDotnetModule rec {
  pname = "DiscordWikiBot";
  version = "0-unstable-2026-08-20";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = pname;
    rev = "bea0e0d57daa8310b2f07e50fc0b8a98e3a464c4";
    hash = "sha256-MHuecj6zGqR7i50siO+BPxXhFA2MylZVT8sB+9xt4g8=";
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
