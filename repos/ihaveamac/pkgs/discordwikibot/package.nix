{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  lib,
}:

buildDotnetModule rec {
  pname = "DiscordWikiBot";
  version = "0-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = pname;
    rev = "7a7a980b77e4234a1bb587ba5d5e475351cbed6d";
    hash = "sha256-qax3RujX4cbgdEFhgOCR/jlV208lv/7/o49kcYmkq4w=";
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
