{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, darwin
}:

rustPlatform.buildRustPackage rec {

  pname = "maa-cli";
  version = "0.4.0-beta.3";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${version}";
    sha256 = "sha256-QMMGa139DHqEo06PGfgwLOh8/qLT9AJQf7cBfsLyaCg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optional stdenv.isDarwin [
    darwin.Security
  ];

  # https://github.com/MaaAssistantArknights/maa-cli/pull/126
  buildNoDefaultFeatures = true;
  buildFeatures = [ "git2" ];

  # read 'config::asst::tests::resource_config::use_user_resource' panicked at maa-cli/src/config/asst.rs:841:40:
  # called `Result::unwrap()` on an `Err` value: Os { code: 13, kind: PermissionDenied, message: "Permission denied" }
  doCheck = false;

  cargoSha256 = "sha256-he3hsaA9SuXRUOPIFDHHlNbdeQQK3Pr52+lWX5WC65M=";

  meta = with lib; {
    description = "A simple CLI for MAA by Rust.";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = licenses.agpl3;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "maa";
  };

}
