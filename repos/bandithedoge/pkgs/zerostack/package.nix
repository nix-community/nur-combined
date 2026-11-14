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

  aws-lc,
  mold,
  pkg-config,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zerostack";
  version = "1.8.6";
  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lexZZHDAMsaRyoaa7ptxMUWNZmj/1Mv8apMhbBep6zU=";
  };

  cargoHash = "sha256-szlDZa4Z9tG+YQWpwcAmjtZSo96ss7nBOLN8nZTb7no=";
  buildFeatures =
    lib.optional withAcp "acp"
    ++ lib.optional withAdvisor "advisor"
    ++ lib.optional withHooks "hooks"
    ++ lib.optional withMemory "memory"
    ++ lib.optional withMultimodal "multimodal"
    ++ lib.optional withPdf "pdf";

  nativeBuildInputs = [
    mold
    pkg-config
  ];

  buildInputs = [
    aws-lc
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

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
