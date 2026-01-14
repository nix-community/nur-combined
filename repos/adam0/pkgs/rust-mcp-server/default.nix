{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hHygSzk4gEOSOqMf6TSaxy1f3Ett4XniiUmoG2Lr4+A=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-MpPIFYIefO4dCytY9Mz2A9J8YuGNPLu6Dfp6nParYEY=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = "rust-mcp-server";
  };
}
