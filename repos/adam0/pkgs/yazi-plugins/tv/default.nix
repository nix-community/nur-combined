{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "tv.yazi";
  version = "0-unstable-2026-02-08";

  src = fetchFromGitHub {
    owner = "cap153";
    repo = pname;
    rev = "b6b1f123bec3e0db59bc2e4dce929e116a5465a3";
    hash = "sha256-VIs8BYbXbXVSrlKpmYAhuahIiWR4PWzjKZvOm+J6TBk=";
  };

  meta = {
    description = "Yazi's fuzzy finder plugin, but using television";
    homepage = "https://github.com/cap153/tv.yazi";
    license = lib.licenses.mit;
  };
}
