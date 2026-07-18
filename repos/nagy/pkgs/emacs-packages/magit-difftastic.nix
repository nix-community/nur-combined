{
  lib,
  fetchFromGitHub,
  melpaBuild,
  magit,
  difftastic,
}:

melpaBuild {
  pname = "magit-difftastic";
  version = "0-unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "rschmukler";
    repo = "magit-difftastic";
    rev = "0df64c67ba4b73cca705f72f7357aedce82f8529";
    hash = "sha256-IeACEonsqh3SLiGNVgTGEO6G0YqgG5boKkdwR0NfnC8=";
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
