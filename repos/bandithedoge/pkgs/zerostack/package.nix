{
  withAcp ? true,
  withAdvisor ? true,
  withHooks ? true,
  withMemory ? true,
  withMultimodal ? true,
  withPdf ? true,

  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  mold,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zerostack";
  version = "1.8.4";
  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1NYNZkzULkQPSh1yuYD5abTpXSak+Y3f0ex0ZaArEaU=";
  };

  cargoHash = "sha256-fLDhu1sFyyyPMXPGJ6S/AbRIH76jTfIy9mOYmH+mQsw=";
  buildFeatures =
    lib.optional withAcp "acp"
    ++ lib.optional withAdvisor "advisor"
    ++ lib.optional withHooks "hooks"
    ++ lib.optional withMemory "memory"
    ++ lib.optional withMultimodal "multimodal"
    ++ lib.optional withPdf "pdf";

  nativeBuildInputs = [ mold ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalistic coding agent written in Rust, optimized for memory footprint and performance";
    homepage = "https://github.com/gi-dellav/zerostack";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "zerostack";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
