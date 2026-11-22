{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "wakaru";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "pionxzh";
    repo = "wakaru";
    rev = "v${version}";
    hash = "sha256-SDpB2lrbzVxqhlJyd0iF1QmK3Mj7HV+9ZFigChyfuJI=";
  };

  cargoHash = "sha256-/KrAIkGtj2vgLqEEVsEC6elHlYQrCakkMLa/9Wmfjjc=";
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
