{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "skull";
  version = "v0.3.0";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "skull";
    rev = "v0.3.0";
    hash = "sha256-8b/rspbrogcjsBMEEPKk8RSBK0ct2DTa57CzE1FDLyQ=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "git repos organized by install tool";
    homepage = "https://github.com/mipmip/skull";
    license = licenses.mit;
  };
}
