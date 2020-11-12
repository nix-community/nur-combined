{...}:
let
  dotenvGit = builtins.fetchGit {
    url = "https://github.com/lucasew/dotenv";
  };
in import "${dotenvGit}"
