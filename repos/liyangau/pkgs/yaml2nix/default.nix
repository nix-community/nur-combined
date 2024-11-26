{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "yaml2nix";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "euank";
    repo = "yaml2nix";
    rev = "v${version}";
    hash = "sha256-pXYTCfyzjVHeNwVfjMpdmArLAr0cn2x7YV8AUOJew7w=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "serde-nix-0.1.0" = "sha256-5IGKtR8oj6zpWMEpkYdoT5pFNn1Wi/CTWFzBQP1yMpY=";
    };
  };

  meta = with lib; {
    description = "";
    homepage = "https://github.com/euank/yaml2nix";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "yaml2nix";
  };
}
