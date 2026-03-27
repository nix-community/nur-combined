{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-aXULI7zVh25wWy+w9zNyyRfxuXSV7MMUFIghScCQVlg=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-acR6hs/OhVEG87b8BrX62VV64lahexQoJlpPU3ue6nM=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = pname;
    platforms = platforms.unix;
  };
}
