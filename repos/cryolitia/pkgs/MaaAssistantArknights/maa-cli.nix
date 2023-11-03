{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, darwin
}:

rustPlatform.buildRustPackage rec {

  pname = "maa-cli";
  version = "0.3.12";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    sha256 = "sha256-nTtKTHP11vcmBsp4UD6I5nGNGYI0ASKN8e8ZhvzlZyY=";
  };

  buildInputs = lib.optional stdenv.isDarwin [
    darwin.Security
  ];

  # disable self update: https://github.com/MaaAssistantArknights/maa-cli/pull/44/files
  buildNoDefaultFeatures = true;

  cargoSha256 = "sha256-/18Fj7A/p4CtHokY45CxAsEnjSOybs8tB8DeZc/0ytE=";

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };

}
