{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "therapist";
  version = "0.1.1";
  owner = "M-Komorek";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-VlyGl7mdY7wE14z1rcEaFz4XAJ/pKQPDXI+BPcwuI/E=";
  };

  cargoHash = "sha256-sB0Fz0zTLVrP7Sp60D2LCeL7ECGvYfZmWMciTv6vB4Y=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "Blazingly fast TUI log viewer for multi-GB files.";
    homepage = "https://github.com/M-Komorek/";
    changelog = "https://github.com/M-Komorek//releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "thr";
    maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
