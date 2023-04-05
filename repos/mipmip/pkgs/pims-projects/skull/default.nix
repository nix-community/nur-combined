{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "skull";
  version = "v0.1.3";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "skull";
    rev = "v0.1.3";
    sha256 = "sha256-OAtMwvDzUtvH9YDoxJxRbtV5H1c+NfBkWvQC6d4nwVs=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "git repos organized by install tool";
    homepage = "https://github.com/mipmip/skull";
    license = licenses.mit;
  };
}
