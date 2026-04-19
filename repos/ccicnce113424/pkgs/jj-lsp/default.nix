{
  sources,
  version,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  inherit version;
  cargoLock = sources.cargoLock."Cargo.lock";
  meta = {
    description = "LSP to resolve conflicts in the jj-vcs";
    homepage = "https://github.com/nilskch/jj-lsp";
    license = lib.licenses.mit;
    mainProgram = "jj-lsp";
  };
}
