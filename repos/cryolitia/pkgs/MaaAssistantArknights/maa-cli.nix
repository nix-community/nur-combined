{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, darwin
}:

rustPlatform.buildRustPackage rec {

  pname = "maa-cli";
  version = "0.4.0-beta.1";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    sha256 = "sha256-CPeGFmXfKY+wcfUCz5VX8/ql2vlWNdwp1GkJVcXSvr8=";
  };

  buildInputs = lib.optional stdenv.isDarwin [
    darwin.Security
  ];

  # disable self update: https://github.com/MaaAssistantArknights/maa-cli/pull/44/files
  buildNoDefaultFeatures = true;

  cargoSha256 = "sha256-SIYm8cEDizKGr0pNNRT//ViN7HB6BM+vPzqd/25/0I0=";

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };

}
