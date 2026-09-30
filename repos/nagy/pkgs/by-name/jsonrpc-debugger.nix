{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jsonrpc-debugger";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "shanejonas";
    repo = "jsonrpc-debugger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XlFUXh1bxPDjssUUzYBpYhgAY5PQPjqN+dCk/4b/vx0=";
  };

  cargoHash = "sha256-0SbNWlFCr73xhNtMNRsv2RTJDc2SxnGJUm5ltC58u9E=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "terminal-based TUI JSON-RPC debugger with interception capabilities, built with Rust and ratatui";
    homepage = "https://github.com/shanejonas/jsonrpc-debugger";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "jsonrpc-debugger";
  };
})
