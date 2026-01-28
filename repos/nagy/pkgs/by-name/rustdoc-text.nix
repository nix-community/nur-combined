{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustdoc-text";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "lmmx";
    repo = "rustdoc-text";
    tag = "rustdoc-text-v${finalAttrs.version}";
    hash = "sha256-cGTgnMZjjB/oTnS7D2E9uQAz8MWB6lbOKDzoXc/4J34=";
  };

  cargoHash = "sha256-ydPRMI0t3xeC55IrAADfIMxuTMOGfwtHgdd4VwbrJ00=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  # Attempts to make network connections
  doCheck = false;

  meta = {
    description = "Lightweight CLI tool to view Rust documentation as plain text";
    homepage = "https://github.com/shanejonas/jsonrpc-debugger";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "rustdoc-text";
  };
})
