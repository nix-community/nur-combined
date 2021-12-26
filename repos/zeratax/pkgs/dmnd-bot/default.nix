{ pkgs, fetchFromGitHub }:

pkgs.crystal.buildCrystalPackage rec {
  pname = "dmnd-bot";
  version = "0.2.2";
  src = fetchFromGitHub {
    owner = "ZerataX";
    repo = pname;
    rev = "v${version}";
    sha256 = "023z3x8hijhs4incha7rpvgxh3pqrp3vjkdk5xsy8448g939bgjr";
  };

  format = "shards";

  shardsFile = ./shards.nix;

  buildInputs = [
    pkgs.openssl
  ];

  postPatch = ''
    substituteInPlace spec/syncplay_bot_spec.cr \
        --replace 'syncplay' '${pkgs.syncplay}/bin/syncplay'
  '';

  checkInputs = [
    pkgs.syncplay
  ];
}
