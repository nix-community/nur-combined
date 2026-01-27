{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-MpVK9uha/5zJPMAiF2gXtPqBLge7J7FqnvGBZMAAbHQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-9o6dyOR+R6Pz7v1tsq3vP5KjCu2wT/ALnNFjuhuETdY=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = "rust-mcp-server";
  };
}
