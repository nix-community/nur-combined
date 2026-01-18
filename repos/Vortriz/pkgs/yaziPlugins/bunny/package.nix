{
  lib,
  mkYaziPlugin,
  fetchFromGitHub,
}:
mkYaziPlugin {
  pname = "bunny.yazi";
  version = "unstable-2026-01-08";

  src = fetchFromGitHub {
    owner = "stelcodes";
    repo = "bunny.yazi";
    rev = "6ee99bc743be6a4cbda3e2e44ca8d59e757c5e51";
    hash = "sha256-hTD/gW+xdz5rN3e/hyI9U/E17MlKgDd9sTnfES7SxCo=";
  };

  meta = {
    description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
    homepage = "https://github.com/stelcodes/bunny.yazi";
    license = lib.licenses.mit;
  };
}