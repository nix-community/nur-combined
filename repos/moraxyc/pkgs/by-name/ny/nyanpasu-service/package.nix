{
  lib,
  aws-lc,
  pkg-config,
  rustPlatform,
  replaceVars,
  nix-update-script,

  sources,
  source ? sources.nyanpasu-service,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock;

  buildAndTestSubdir = "nyanpasu_service";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    aws-lc
  ];

  env = {
    # nightly features
    RUSTC_BOOTSTRAP = 1;
  };

  postPatch = ''
    cp ${
      replaceVars ./build.rs {
        COMMIT_DATE = source.date;
        COMMIT_HASH = lib.substring 0 6 finalAttrs.src.rev or "000000";
      }
    } crates/nyanpasu-service-runtime/build.rs
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform privileged service for Nyanpasu";
    homepage = "https://github.com/libnyanpasu/nyanpasu-service";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "nyanpasu-service";
    platforms = lib.platforms.unix;
  };
})
