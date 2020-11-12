{...}:
let
  nixgramGit = builtins.fetchGit {
    url = "https://github.com/lucasew/nixgram";
    rev = "9c6497ed12291bffd2aea9068e73d54fca660f79";
  };
in import "${nixgramGit}"
