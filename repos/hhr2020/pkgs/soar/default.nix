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
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "pkgforge";
    repo = "soar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4QmjDhnO+wpwB/6woa2ObVgfAKJtvzBbx9gl2/QwPno=";
  };

  cargoHash = "sha256-HfYR2b1zn6pgEPC1iDkcI9up9WXI45u3TnS0AVY2gBc=";

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
