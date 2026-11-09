{
  lib,
  fetchFromGitHub,
  melpaBuild,
  magit,
  difftastic,
}:

melpaBuild {
  pname = "magit-difftastic";
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "rschmukler";
    repo = "magit-difftastic";
    rev = "9e5a889a77c807ef731875bf5289f892e7b455ed";
    hash = "sha256-FUdC57YNsNhs+nmEZM/lpJFI5PJajm0rhkr1ly5gxJo=";
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
