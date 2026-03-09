{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-zJkZuhLWHGG7sBd8jT6f4FUyqcb0wqvX5v2x5j9oZdU=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-8tV7dQ4VDea/aUJYKr94ZmLrgwY6+i1d+mQ1zrU6LEw=";

  meta = {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = lib.licenses.unlicense;
    mainProgram = pname;
  };
}
