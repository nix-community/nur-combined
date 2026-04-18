{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "0.9.9-delta";

  src = fetchFromGitHub {
    owner = "kokic";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cNzYPgybmXni/JYz9/1iZEpLn/R0nFV5e+24kSimcHU=";
  };

  cargoHash = "sha256-YdK4DXmOJx+X6HTNqzH/NVct07SwkL4ZS+zAjjHPQ5g=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kokic/kodama";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
