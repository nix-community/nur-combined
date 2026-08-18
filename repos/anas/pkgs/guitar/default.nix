{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, git
}:

let
  pname = "guitar";
  version = "1.0.4";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "asinglebit";
    repo = "guitar";
    rev = "v${version}";
    hash = "sha256-QMQaePeomxh2OeTKHTSLFaphwGbL8mNMPxa6TKDOCZg";
  };

  cargoHash = "sha256-omQ5AQn/3ipf/Em2sb0ry/JRfQ/ENHXGc/Ezw9xV9A8=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    git
    openssl
  ];

  # There is no tests
  doCheck = false;

  meta = {
    description = "A terminal based git client with fast topological & chronological graph rendering";
    homepage = "https://github.com/asinglebit/guitar";
    license = lib.licenses.gpl3Plus;
    mainProgram = "guitar";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
