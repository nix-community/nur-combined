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
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "jarkkojs";
    repo = "tpm2-library";
    tag = finalAttrs.version;
    hash = "sha256-En+6p9ytcUInigzZ9sjhxhUDGN/nxO+9GZl8iBoP+jI=";
  };

  cargoHash = "sha256-kGE+nz6gtwzdGfGi6I68HOxA6Qnd0u86MiEtASm+JlY=";

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
