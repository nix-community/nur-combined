{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  openssl,
  xz,
  zstd,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ubi";
  version = "0.9.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "houseabsolute";
    repo = "ubi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3+cC1X/Ao7x30UCmwUCz/E6HXaIk2G5EDKhgGUKexaE=";
  };

  cargoHash = "sha256-qTzJ3s9tsv30gN3Rz8DJqHhRnQW5svTkWBDkR1ZOlIo=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    openssl
    xz
    zstd
  ];

  postPatch = ''
    # tests require network
    rm -v ubi-cli/tests/ubi.rs
  '';

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "The Universal Binary Installer";
    homepage = "https://github.com/houseabsolute/ubi";
    changelog = "https://github.com/houseabsolute/ubi/blob/${finalAttrs.src.rev}/Changes.md";
    license = [lib.licenses.asl20 lib.licenses.mit];
    platforms = lib.platforms.all;
    mainProgram = "ubi";
  };
})
