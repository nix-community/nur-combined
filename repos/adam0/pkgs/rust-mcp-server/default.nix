{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage rec {
  pname = "rust-mcp-server";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "Vaiz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-5P9sUkiy3Hm6euE7sP6VT9wtbFzXnzuohynvU8EaRI8=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-m3LstvdKrSgrO88mdmi5SW5H5wm9Fs0mFKDFrwAOWOE=";

  meta = with lib; {
    # keep-sorted start
    description = "MCP server for development in Rust";
    homepage = "https://github.com/Vaiz/rust-mcp-server";
    license = licenses.unlicense;
    mainProgram = pname;
    platforms = platforms.unix;
    # keep-sorted end
  };
}
