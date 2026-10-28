{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "wakaru";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "pionxzh";
    repo = "wakaru";
    rev = "v${version}";
    hash = "sha256-v6RGCKj7W1cmLHh1gPfLEZAkD0TUU1z6PnZa+fDXexA=";
  };

  cargoHash = "sha256-AOgkxrRCvtTbe+2tWf6G5UV+bwo1Q7r7z7HXz5MyqNg=";
  # Only the CLI; crates/wasm is a wasm32 cdylib we have no use for.
  cargoBuildFlags = [
    "-p"
    "wakaru-cli"
  ];
  doCheck = false;

  meta = with lib; {
    description = "Unpack. Unminify. Understand.";
    homepage = "https://github.com/pionxzh/wakaru";
    license = licenses.asl20;
    mainProgram = "wakaru";
    platforms = platforms.unix;
  };
}
