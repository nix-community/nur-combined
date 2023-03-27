{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "skull";
  version = "v0.1.2";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "skull";
    rev = "v0.1.2";
    sha256 = "sha256-J+NVXNJD4hJTgSMLmBRMZUoyM+xO1/AM42fvNDPKTjY=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "git repos organized by install tool";
    homepage = "https://github.com/mipmip/skull";
    license = licenses.mit;
  };
}
