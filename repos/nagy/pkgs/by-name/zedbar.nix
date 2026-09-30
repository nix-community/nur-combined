{
  lib,
  fetchFromGitHub,
  rustPlatform,
  zbar,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zedbar";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "eventualbuddha";
    repo = "zedbar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r/sQknpi8v3YemIXuH0r8rlFBHIsiqcGt6VlA3MRWAg=";
  };

  cargoHash = "sha256-UJkFGTKF+UNBXbCwcobsfFE4tGkLRl7xqDftn6rys3E=";

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
