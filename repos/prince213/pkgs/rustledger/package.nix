{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustledger";
  version = "0.21.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rustledger";
    repo = "rustledger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sGvkUxxa5bEMz0bC++i/4SBjlBesLBYpqK71tTQJNwI=";
  };

  cargoHash = "sha256-sI8fj4bsh9IVi31po2iACwFWtQ8VemnBJDKA5M1o2m8=";

  # Disable cargo-auditable until https://github.com/rust-secure-code/cargo-auditable/issues/124 is solved.
  auditable = false;

  # cost::tests::booked_cost_new_panics_in_debug_on_overflow
  # cost::tests::booked_cost_new_rejects_inconsistent_pair_in_debug
  # cost::tests::booked_cost_new_rejects_zero_units_in_debug
  checkType = "debug";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Rust implementation of Beancount";
    homepage = "https://rustledger.github.io/";
    downloadPage = "https://github.com/rustledger/rustledger/releases";
    changelog = "https://github.com/rustledger/rustledger/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "rledger";
  };
})
