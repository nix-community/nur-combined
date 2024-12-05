{ fetchFromGitHub, buildDotnetModule , lib}:

buildDotnetModule rec {
  pname = "discordwikibot";
  version = "2024-11-11";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = "DiscordWikiBot";
    rev = "ffc5299cd3b6e81c140e444359827bd6cd9b914d";
    hash = "sha256-bcFin0ovZ7QwDJV/JHpYTSZLLP/i5D5aJSLTsisefwI=";
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
