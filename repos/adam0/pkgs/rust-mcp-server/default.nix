{
  lib,
  rustPlatform,
  fetchCrate,
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.1";

  src = fetchCrate {
    inherit
      pname
      version
      ;

    hash = "sha256-mDD46pkBwbRC9C7ilgOIPmXdI4YV0bIlIoCwj1FkAV4=";
  };

  cargoHash = "sha256-MpPIFYIefO4dCytY9Mz2A9J8YuGNPLu6Dfp6nParYEY=";

  meta = with lib; {
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = "rust-mcp-server";
  };
}
