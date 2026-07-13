{
  lib,
  rustPlatform,
  fetchFromGitHub,
  tpm2-tss,
  openssl,
  pkg-config,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mkcreds";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "codgician";
    repo = "mkcreds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iiSD3e6VvUBkDWTIzsJkUPprZiI3Qc1cB2XQu8vjcl0=";
  };

  cargoHash = "sha256-Jq+UfOE0gylsKZp/zgvU8wBnizPzGuEamaVioWRPz6k=";

  strictDeps = true;
  OPENSSL_NO_VENDOR = "1";
  TSS2_ESYS_2_3 = "1";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    tpm2-tss
    openssl
  ];

  doCheck = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/mkcreds --help | grep -Fq -- "--tpm2-pcrs"

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Create systemd-creds compatible TPM2-sealed credentials with custom PCR values";
    homepage = "https://github.com/codgician/mkcreds";
    changelog = "https://github.com/codgician/mkcreds/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "mkcreds";
  };
})
