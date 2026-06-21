{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
}:

buildDotnetModule rec {
  pname = "DiscordWikiBot";
  version = "0-unstable-2026-06-18";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = pname;
    rev = "0cd366964766b323ba0a936dc48626f88a9efb66";
    hash = "sha256-gjZugzwpfl3W9kVkkES98+31IxcDGR2xKFJyQvl/8cg=";
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
