{
  lib,
  fetchFromGitHub,
  rustPlatform,
  zbar,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zedbar";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "eventualbuddha";
    repo = "zedbar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n3dL0XbeRXOY967p4nCDgFLEXvHqA0TCoodMU47xFZw=";
  };

  cargoHash = "sha256-+Hixz8DwJRwW2v9+sEf4cqc3DFlwLFwfexFhD3ZdDiY=";

  nativeCheckInputs = [ zbar ];

  meta = {
    description = "Pure Rust barcode and QR code scanning library with a CLI";
    homepage = "https://github.com/eventualbuddha/zedbar";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "zedbarimg";
    platforms = lib.platforms.linux;
  };
})
