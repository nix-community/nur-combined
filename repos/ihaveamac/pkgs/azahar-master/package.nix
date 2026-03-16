{ stdenv, azahar, fetchFromGitHub }:

azahar.overrideAttrs (final: prev: {
  pname = "azahar";
  version = "2125.0-rc1-unstable-2026-03-15";
  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    rev = "ae9972b6beb962e9d02180cc8507d801bac069cd";
    hash = "sha256-0ByEHMXD+h6gtwrScO10Id8Km8CTpbusonFPvE6TQtE=";
    fetchSubmodules = true;
  };

  meta = prev.meta // {
    description = prev.meta.description + " (master branch)";
    # empty output
    broken = stdenv.isDarwin;
  };
})
