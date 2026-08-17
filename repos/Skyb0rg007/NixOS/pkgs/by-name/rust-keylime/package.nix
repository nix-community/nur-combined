{
  fetchFromGitHub,
  fetchpatch,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  tpm2-tss,
  nixosTests,
}:
let
  # Bug in tpm2-tss 4.2.0
  # Remove once https://github.com/tpm2-software/tpm2-tss/pull/3123 is merged
  tpm2-tss-keylime = tpm2-tss.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/tpm2-software/tpm2-tss/commit/1a02ac3395c028cccf176d47e95a0bcb30d0987a.patch";
        hash = "sha256-AldDncNE+MmLzIFW2LLvuHWh9pvvCtBwwT9KIeSdGWQ=";
      })
    ];
  });
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-keylime";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "keylime";
    repo = "rust-keylime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+MypjFxEmuxgQilgtnAyfw1a0yf0QRpfENHTBhuK/94=";
  };

  cargoHash = "sha256-eVn9R5Ue9cPB8Xin2rVldHDycGWvyCCQ7RuVMRkb2yM=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl.dev
    tpm2-tss-keylime.dev
  ];

  passthru.tests.nixos = nixosTests.keylime;

  meta = {
    description = "Rust implementation of the keylime agent";
    longDescription = ''
      This is a Rust implementation of the keylime agent.
      Keylime is system integrity monitoring system that has the following features:

      - Exposes TPM trust chain for higher-level use
      - Provides an end-to-end solution for bootstrapping node cryptographic identities
      - Securely monitors system integrity

      The rust-keylime agent is the official agent and replaces the Python implementation.
    '';
    homepage = "https://keylime.dev";
    downloadPage = "https://github.com/keylime/rust-keylime";
    changelog = "https://github.com/keylime/rust-keylime/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "keylime_agent";
    platforms = lib.platforms.linux;
  };
})
