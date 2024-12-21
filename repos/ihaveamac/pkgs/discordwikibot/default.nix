{ fetchFromGitHub, buildDotnetModule , lib}:

buildDotnetModule rec {
  pname = "discordwikibot";
  version = "2024-12-20";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = "DiscordWikiBot";
    rev = "eab36a8f51114bcca7ff2f12ca6b8cfa6246fdfc";
    hash = "sha256-itSXViIisCksCfKNHaRih9+A9NbgaXKzg64g+5h1VNA=";
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
