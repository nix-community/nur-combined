{ azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0-alpha2-unstable-2026-02-23";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "d721cbe29bfca9fa38f2a4443234ce617c02d23c";
    hash = "sha256-avGutXhOgx7hCeq9y+37w5XeG+eVquML1ma1h3ad6e4=";
    fetchSubmodules = true;
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
  };
})
