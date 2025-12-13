{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jsonrpc-debugger";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "shanejonas";
    repo = "jsonrpc-debugger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zFEhw14bHHuSzU9S5FDxS9lZBvJ/IfGyAKHLHsh1ScE=";
  };

  cargoHash = "sha256-GhEq+mazRTfGa08Sps5O+sacGXsIdF2cOkppLVylq2E=";

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
