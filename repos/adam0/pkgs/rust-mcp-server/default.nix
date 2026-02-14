{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-mytNVBXPUZNjkxjEVjAinLluZI4Lr6/LB2Ti9EurAMw=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-2c7icCuy21874wKWUf1JHyom94Vmnr+U2pDm03GuJjY=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = "rust-mcp-server";
  };
}
