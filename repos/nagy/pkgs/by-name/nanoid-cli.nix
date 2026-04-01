{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nanoid-cli";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jlyonsmith";
    repo = "nanoid_cli";
    tag = finalAttrs.version;
    hash = "sha256-EHKSqOrnpFHdf6U+OHvflJxAb/qMkYvFctD8BcIQ3rA=";
  };

  cargoHash = "sha256-pdO8E/uZ1W2ioS09aUjyqI9x6Qe1xHnZL9UaQTb6c+M=";

  meta = {
    description = "Rust based command line interface for the Nanoid library";
    homepage = "https://github.com/jlyonsmith/nanoid_cli";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "nanoid-cli";
  };
})
