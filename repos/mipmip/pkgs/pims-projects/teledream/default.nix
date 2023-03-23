{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "teledream";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "teledream";
    rev = "v0.1.0";
    sha256 = "sha256-00CRcZGBweLFzqtDO/+gImYB+SFTs9uK209yNZYmaPc=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "Teledream, connecting Stable Diffusion to telegram";
    homepage = "https://github.com/mipmip/teledream";
    license = licenses.mit;
  };
}
