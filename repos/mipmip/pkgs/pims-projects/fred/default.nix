{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "fred";
  version = "v0.5.0";

  src = fetchFromGitHub {
    owner = "linden-project";
    repo = "fred";
    rev = "v0.5.0";
    sha256 = "sha256-00CRcZGBweLFzqtDO/+gImYB+SFTs9uK209yNZYmaPc=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  meta = with lib; {
    description = "Fred, a cli front matter editor";
    homepage = "https://github.com/linden-project/fred";
    license = licenses.mit;
  };
}
