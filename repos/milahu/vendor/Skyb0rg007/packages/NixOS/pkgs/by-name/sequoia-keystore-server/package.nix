{
  lib,
  fetchFromGitLab,
  rustPlatform,
  rustc,
  pkg-config,
  pcsclite,
  tpm2-tss,
  nettle,
  capnproto,
  nix-update-script,
  sequoia-chameleon-gnupg,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequoia-keystore-server";
  version = "0.2.1";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "sequoia-keystore";
    tag = "server/v${finalAttrs.version}";
    hash = "sha256-wZJZH7Ki+7ONdvFk4sBhetdX9d3CychOcgXINNoYHmg=";
  };

  cargoHash = "sha256-ysb1OZp3zPvkRLiielrEcjVxDDt0LCIqpKvuOMgkDGg=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    capnproto
  ];
  buildInputs = [
    pcsclite
    tpm2-tss
    nettle
  ];

  nativeCheckInputs = [ sequoia-chameleon-gnupg ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex=server/v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Private key store for Sequoia";
    homepage = "https://gitlab.com/sequoia-pgp/sequoia-keystore";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.intersectLists lib.platforms.linux rustc.meta.platforms;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "sequoia-keystore";
  };
})
