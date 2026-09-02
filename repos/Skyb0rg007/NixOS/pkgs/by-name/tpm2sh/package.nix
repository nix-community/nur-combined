{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  nix-update-script,
  versionCheckHook,
  installShellFiles,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tpm2sh";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jarkkojs";
    repo = "tpm2-library";
    tag = finalAttrs.version;
    hash = "sha256-vare2saQIICQdAM7jm/CeAnWnqmdFN81CCmv+xKyn8M=";
  };

  cargoHash = "sha256-Dp5h5sep/z3328nnfHkhpugodp0iPWEgSendRgbimVE=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    openssl
  ];

  buildFlags = [
    "--package=sh"
  ];

  postInstall = ''
    installManPage crates/sh/tpm2sh.1
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # Tests require a TPM
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for accessing TPM 2.0 chips on Linux.";
    homepage = "https://github.com/jarkkojs/tpm2-library";
    mainProgram = "tpm2sh";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
