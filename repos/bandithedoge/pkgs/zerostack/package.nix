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
  version = "1.8.5";
  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-i6J+7OxXa3tD0Yq/yfHmMPf5kMn51tWvaXYzgRj6YS8=";
  };

  cargoHash = "sha256-zmVbxKETpuFgL9SUb2OCq/t80r2ai1tM/vpu4KhWf24=";
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
