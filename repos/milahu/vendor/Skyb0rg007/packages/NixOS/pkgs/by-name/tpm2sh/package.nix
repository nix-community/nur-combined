{
  lib,
  fetchFromGitLab,
  rustPlatform,
  pkg-config,
  openssl,
  nix-update-script,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tpm2sh";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "tpm-protocol";
    repo = "tpm2sh";
    tag = finalAttrs.version;
    hash = "sha256-dStussWZkQTDeAnul3jFnhQ5LOoxJtvT7RHpHBwyeKg=";
  };

  cargoHash = "sha256-Q1yTnLu32T/58OYaaq3Wl0uLLaFMeqwMLDLPHvGjxbc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # Tests require a TPM
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for accessing TPM 2.0 chips on Linux.";
    homepage = "https://gitlab.com/tpm-protocol/tpm2sh";
    mainProgram = "tpm2sh";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
