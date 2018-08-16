{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "minibar-${version}";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "canassa";
    repo = "minibar";
    rev = "c8ecd61";
    sha256 = "1k718zrjd11rw93nmz2wxvhvsai6lwqfblnwjpmkpnslcdan7641";
  };
}
