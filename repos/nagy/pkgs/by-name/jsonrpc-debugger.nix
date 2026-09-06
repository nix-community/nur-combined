{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jsonrpc-debugger";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "shanejonas";
    repo = "jsonrpc-debugger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-trkrcI3zgTSkDEdXfPjRMYOij296YkSZtTxJEocrcPI=";
  };

  cargoHash = "sha256-R//RlcwlE0ombrQSgZSFKHruZU5PsYzbuNT2Tp7hcs4=";

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
