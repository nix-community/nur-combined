{
  lib,
  fetchFromGitHub,
  melpaBuild,
  magit,
  difftastic,
}:

melpaBuild {
  pname = "magit-difftastic";
  version = "0-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "rschmukler";
    repo = "magit-difftastic";
    rev = "9394ab5e7a29d4507cc69471ea13a14a4bf78da1";
    hash = "sha256-+/eF/FFgwdRX0wX2reCoNXmwIgH7ZsoJLJXGKqN6Vsk=";
  };

  packageRequires = [
    magit
    difftastic
  ];

  meta = {
    homepage = "https://github.com/rschmukler/magit-difftastic";
    description = "Difftastic-rendered, stageable sections in Magit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
