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
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jarkkojs";
    repo = "tpm2-library";
    tag = finalAttrs.version;
    hash = "sha256-yGDpvvwyEEqa5JchrrYHHaJGyNXdydLzSFWm4LWZo9Y=";
  };

  cargoHash = "sha256-qdUej0cRBbffdPl44ne9B8PcmlJVHg0SmFMJij5gKGM=";

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
