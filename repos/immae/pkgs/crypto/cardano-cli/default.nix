{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  name = "cardano-cli-${version}";
  version = "master";

  src = fetchFromGitHub {
    owner = "input-output-hk";
    repo = "cardano-cli";
    rev = "ed064d5a3b96c23b52bb20ca49da9cb8764a2e0f";
    sha256 = "07y5ssar6aq93snrvmapk05zmym4w23ydvjn2njp8saxk23ivqsg";
    fetchSubmodules = true;
  };

  cargoSha256 = "0j68dsqahvgpa9ms62149530lbfa55lmpd56rgdxkrh2z32lshs8";
  verifyCargoDeps = true;
}
