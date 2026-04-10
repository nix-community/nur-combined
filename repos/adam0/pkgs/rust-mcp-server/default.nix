{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/6n6o9XuP73wGPEaRpTRJrviF9jVTVxXe5B1Dr4eFOc=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-DDfdAnu2WBno+jmMknmyeyJuuhChTEElnCN8aYdIxP4=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = pname;
    platforms = platforms.unix;
  };
}
