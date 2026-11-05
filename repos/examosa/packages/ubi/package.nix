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
  version = "0.13.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "houseabsolute";
    repo = "ubi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bD6nTaGQAazMwgGB8iaV25O5wFoQus00nlkXgSBjZak=";
  };

  cargoHash = "sha256-+fmJXB8Pl4PFiPG23tPX2f3eBiWvIYvICpIUn3K3DA0=";

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
    changelog = "https://github.com/houseabsolute/ubi/blob/${finalAttrs.src.tag}/Changes.md";
    license = [lib.licenses.asl20 lib.licenses.mit];
    maintainers = [lib.maintainers.examosa];
    mainProgram = "ubi";
    platforms = lib.platforms.all;
  };
})
