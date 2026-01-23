{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dRSgi2jaeIzOCbfo4850aBSLoin4HEQ6tXGnvc3E5rk=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-z732tS524RY5nqyciJCzvOq4v5XXsFv48F9nNEpmThI=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = "rust-mcp-server";
  };
}
