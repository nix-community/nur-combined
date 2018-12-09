{ stdenv, fetchFromGitLab, urn, ... }:

urn.overrideDerivation (old: rec {
  version = "0.7.2-pre";
  name = "urn-${version}";
  src = fetchFromGitLab {
    owner = "urn";
    repo = "urn";
    rev = "ff1049713dcc7ded5968a813627543281e5f299f";
    sha256 = "1kcrrdk3b6kljh0jk4s916l3f3ixfx2mdazr6mr9l2jsdcki7zxz";
  };
})
