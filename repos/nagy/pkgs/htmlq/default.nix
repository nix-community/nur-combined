{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "htmlq";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "mgdm";
    repo = "htmlq";
    rev = "v${version}";
    hash = "sha256-kZtK2QuefzfxxuE1NjXphR7otr+RYfMif/RSpR6TxY0=";
  };

  cargoHash = "sha256-r9EnQQPGpPIcNYb1eqGrMnRdh0snIa5iVsTYTI+YErY=";

  meta = with lib; {
    description = "Like jq, but for HTML";
    homepage = "https://github.com/mgdm/htmlq";
    license = with licenses; [ mit ];
  };
}
