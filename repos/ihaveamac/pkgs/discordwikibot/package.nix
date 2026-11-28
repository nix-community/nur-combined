{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  lib,
}:

buildDotnetModule rec {
  pname = "DiscordWikiBot";
  version = "0-unstable-2026-11-26";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = pname;
    rev = "e90f55be53ac53164a7d3f5ea84c44880b768d97";
    hash = "sha256-HOitNihcVn/xIXGHOBfpGvdE4xxqDSiGnhyQQuRzCyY=";
  };

  projectFile = "DiscordWikiBot/DiscordWikiBot.csproj";
  nugetDeps = ./deps.json;

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  meta = with lib; {
    description = "Discord bot for Wikimedia projects and MediaWiki wiki sites";
    homepage = "https://github.com/stjohann/DiscordWikiBot";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "DiscordWikiBot";
  };
}
