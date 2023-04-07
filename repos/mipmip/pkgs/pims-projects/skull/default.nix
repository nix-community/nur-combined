{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "skull";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "skull";
    rev = "v0.2.0";
    sha256 = "sha256-duvb4a+bREIYLU12H4NjyVTuXC8ZBIEPCBHcNOjk8n4=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "git repos organized by install tool";
    homepage = "https://github.com/mipmip/skull";
    license = licenses.mit;
  };
}
