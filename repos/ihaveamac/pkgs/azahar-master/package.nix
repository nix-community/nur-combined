{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0-rc1-unstable-2026-03-17";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "ab39df3ff047b2a8ae962fad51f8c83d5d995d4e";
    hash = "sha256-WohUIYMJSFNg3Vl8lqD/oaH92uv3OFNfsVZNDgoezRE=";
    fetchSubmodules = true;
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    # empty output
    broken = stdenv.isDarwin;
  };
})
