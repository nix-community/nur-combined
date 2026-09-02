{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  cacert,
  openssl,
  xz,
  zstd,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ubi";
  version = "0.12.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "houseabsolute";
    repo = "ubi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rLrh+8onizKeM3azqO20X0QH0lFy2F3zPhFqQ+FpM3Y=";
  };

  cargoHash = "sha256-+jWn5mM2jD99wdwgIx3CEl88T9aZP9HdHAWPI/dehEY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    openssl
    xz
    zstd
  ];

  nativeCheckInputs = [
    cacert
  ];

  postPatch = ''
    # tests require network
    rm -v ubi-cli/tests/ubi.rs
  '';

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    description = "The Universal Binary Installer";
    homepage = "https://github.com/houseabsolute/ubi";
    changelog = "https://github.com/houseabsolute/ubi/blob/${finalAttrs.src.rev}/Changes.md";
    license = [lib.licenses.asl20 lib.licenses.mit];
    platforms = lib.platforms.all;
    mainProgram = "ubi";
  };
})
