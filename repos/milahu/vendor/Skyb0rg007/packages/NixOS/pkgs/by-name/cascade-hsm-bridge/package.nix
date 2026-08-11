{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo,
  softhsm,
  installShellFiles,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cascade-hsm-bridge";
  version = "0.1.0-beta1";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "cascade-hsm-bridge";
    tag = finalAttrs.version;
    hash = "sha256-TMh4kpJUbPujQlzWMlh8qkn4LOr55l5HHelE2NP8rEY=";
  };

  cargoHash = "sha256-QLsbAEko/uNLryp4c3UGPWQk4rU0jGg++EureMEk3zE=";

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    cargo
    softhsm
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  postInstall = ''
    installManPage ./doc/manual/build/man/*.{1,5}
  '';

  preCheck = ''
    export SOFTHSM2_PATH="${lib.getLib softhsm}/lib/softhsm/libsofthsm2.so"
    # Build the debug release
    cargo build --bin cascade-hsm-bridge
  '';

  meta = {
    description = "KMIP to PKCS#11 bridge for Cascade";
    homepage = "https://github.com/NLnetLabs/cascade-hsm-bridge";
    mainProgram = "cascade-hsm-bridge";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
