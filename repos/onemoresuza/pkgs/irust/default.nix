{
  lib,
  fetchFromGitHub,
  makeWrapper,
  rustPlatform,
  cargo,
  cargo-edit,
  cargo-show-asm,
  cargo-expand,
  rustfmt,
  rust-analyzer,
}:
rustPlatform.buildRustPackage rec {
  pname = "IRust";
  version = "1.71.2";

  src = fetchFromGitHub {
    owner = "sigmaSd";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6qxkz7Pf8XGORo6O4eIwTcqBt+8WBp2INY81YUCxJts=";
  };

  cargoSha256 = "sha256-VZXxz3E8I/8T2H7KHa2IADjqsG2XHBNhwq/OBsq3vHs=";

  buildInputs = [makeWrapper];

  #
  # Tests do not seem to work inside the sandbox.
  #
  doCheck = false;

  wrapperPath = lib.makeBinPath [
    cargo
    cargo-edit
    cargo-show-asm
    cargo-expand
    rustfmt
    rust-analyzer
  ];

  postFixup = ''
    wrapProgram "$out/bin/irust" \
      --suffix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "Cross Platform Rust Repl";
    homepage = "https://github.com/sigmaSd/IRust/";
    license = licenses.mit;
    mainProgram = "irust";
  };
}
