{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "confirm-open.yazi";
  version = "0-unstable-2026-03-10";

  src = fetchFromGitHub {
    owner = "walldmtd";
    repo = pname;
    rev = "058b9166fb4279fa5fcf5f11d3883bd94c3c937d";
    hash = "sha256-AvY7O5XKD0M0W6bd9ah3aY4wj32E910uCYSFrkmxZoo=";
  };

  meta = {
    description = "Yazi plugin that confirms before opening many files";
    homepage = "https://github.com/walldmtd/confirm-open.yazi";
    license = lib.licenses.mit;
  };
}
