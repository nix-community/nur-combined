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
  version = "1.70.0";

  src = fetchFromGitHub {
    owner = "sigmaSd";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-chZKesbmvGHXwhnJRZbXyX7B8OwJL9dJh0O1Axz/n2E=";
  };

  cargoSha256 = "sha256-uS4+s3r1ufjA5bz/Oskuq5S25IMieooEeS+Tqgn/6cA=";

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
