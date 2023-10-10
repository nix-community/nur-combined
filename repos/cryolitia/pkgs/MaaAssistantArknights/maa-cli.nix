{ maintainers
, stdenv
, lib
, fetchFromGitHub
, rustPlatform
, darwin
}:

rustPlatform.buildRustPackage rec {

  pname = "maa-cli";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    sha256 = "sha256-Xw5RKDjgys0VStpMFfOtC2E8f4A8YsjW6NKk+J2j5S8";
  };

  buildInputs = lib.optional stdenv.isDarwin [
    darwin.Security
  ];

  # disable self update: https://github.com/MaaAssistantArknights/maa-cli/pull/44/files
  buildNoDefaultFeatures = true;

  cargoSha256 = "sha256-xw1L33i+kw7t085tTC2IkC52GPPVWtXIb7wf0FtsvJ0=";

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };

}
