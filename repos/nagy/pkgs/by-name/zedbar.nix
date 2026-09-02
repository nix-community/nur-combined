{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zedbar";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "eventualbuddha";
    repo = "zedbar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lXDSUIB6cWRS2/PzuqgDhukz+ecsfP2ghAmMP+zCd/s=";
  };

  cargoHash = "sha256-hhr8IaYwSitxnXHtDeuPf9tC/3pkCSTjk4/aAHZjYiA=";

  meta = {
    description = "Pure Rust barcode and QR code scanning library with a CLI";
    homepage = "https://github.com/eventualbuddha/zedbar";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "zedbarimg";
    platforms = lib.platforms.linux;
  };
})
