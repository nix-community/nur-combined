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
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "pkgforge";
    repo = "soar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oh/CeYemkhN04O5ffwL4/rTtctwXlVez9++mBRNqlVo=";
  };

  cargoHash = "sha256-qRmIIVv/4sjBDZuCRrOdfwh5dSdhg20DnKajrdkmZcI=";

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
