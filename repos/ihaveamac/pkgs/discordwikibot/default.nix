{ fetchFromGitHub, buildDotnetModule , lib}:

buildDotnetModule rec {
  pname = "discordwikibot";
  version = "2024-09-12";

  src = fetchFromGitHub {
    owner = "stjohann";
    repo = "DiscordWikiBot";
    rev = "edb5ae701d01f28a034594f1ad9022bb7fc29ec5";
    hash = "sha256-pErRflwlAMEDzfGh5XVr+DouG2G8GtKTVOlUUfNNIew=";
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
