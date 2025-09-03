{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pluscodes";
  version = "0.5.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-teoPhgMTImBJgUCw2NrPyacSAuLfcZenqkx7Se43asQ=";
  };

  cargoHash = "sha256-56iK+7W+FCmq8CO0g2f+/gXg/MfjR9wwT4PncoLPC4k=";

  meta = {
    description = "Implementation of plus codes, to be used as CLI tool or crate";
    homepage = "https://github.com/janne/pluscodes-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pluscodes";
  };
})
