{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "rustdoc-md";
  version = "0-unstable-2025-10-28";

  src = fetchFromGitHub {
    owner = "tqwewe";
    repo = "rustdoc-md";
    rev = "427b1e781a96290d1044d8d29996100e6ed88b1c";
    hash = "sha256-nPSwhIA9D0NBFWudqzDB8cBEpPtpCdKcdkpFJHhwXEY=";
  };

  cargoHash = "sha256-W3kYntxQ5vxy1jIF3jIewxf4cDdhNBLkaadEJB9kGuY=";

  meta = {
    description = "Convert Rust documentation JSON into clean, organized Markdown files";
    homepage = "https://github.com/tqwewe/rustdoc-md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "rustdoc-md";
  };
}
