{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arbol";
  version = "0.1.0-unstable-2026-05-12";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "joaommartins";
    repo = "arbol";
    rev = "3edfaeba2257b3b8bb87c798f4edd6f3a777bb1a";
    hash = "sha256-47+0yUID8tkqe08Zy0Ubc3gfY+lN7sDURj1nMMKMJLI=";
  };

  cargoHash = "sha256-WBLu00DP9UJgWkoGBRJCFVFl6xr4bfaS/HXJ5MT+t6s=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=unstable" ]; };

  meta = {
    description = "Tree-sitter powered Rust workspace explorer";
    homepage = "https://github.com/joaommartins/arbol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "arbol";
  };
})
