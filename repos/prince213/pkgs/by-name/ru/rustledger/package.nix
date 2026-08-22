{
  lib,
  fetchFromGitHub,
  rustPlatform,

  # nativeInstallCheckInputs
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustledger";
  version = "0.22.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rustledger";
    repo = "rustledger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KNInYM3pVhVxTyP94FJJFOKMy25u+NFOqO1ZR+NXc6A=";
  };

  cargoHash = "sha256-q6cUezD2VJICm2dfp8kYV4TvUbkBEY3Xfs0EBErRa60=";

  # Disable cargo-auditable until https://github.com/rust-secure-code/cargo-auditable/issues/124 is solved.
  auditable = false;

  # checkType = "debug";
  checkFlags = [
    "--skip=cost::tests::booked_cost_new_panics_in_debug_on_overflow"
    "--skip=cost::tests::booked_cost_new_rejects_inconsistent_pair_in_debug"
    "--skip=cost::tests::booked_cost_new_rejects_zero_units_in_debug"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Rust implementation of Beancount";
    homepage = "https://rustledger.github.io/";
    downloadPage = "https://github.com/rustledger/rustledger/releases";
    changelog = "https://github.com/rustledger/rustledger/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "rledger";
  };
})
