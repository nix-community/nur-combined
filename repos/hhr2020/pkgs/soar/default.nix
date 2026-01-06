{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "soar";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "pkgforge";
    repo = "soar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-081wCf5ICT32wiVnGbksr9Z2iYCcaB9Ba8lmaJZ3ekk=";
  };

  cargoHash = "sha256-h3BkbVKYEY9w2G4kVELc7iwInbk4tw2qrlzb8mZm8oE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "Package manager for Static Binaries and Portable Formats";
    homepage = "https://github.com/pkgforge/soar";
    changelog = "https://github.com/pkgforge/soar/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "soar";
  };
})
