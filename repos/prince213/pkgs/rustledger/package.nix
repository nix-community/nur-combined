{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustledger";
  version = "0.15.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rustledger";
    repo = "rustledger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hwLaqMnM/5wwIb/mg8pE8J0mxbnz02RV59kXywwYhvs=";
  };

  cargoHash = "sha256-on9xh8MiOLOHztVC5SbpvNPzqfEPJ3HFz2vWMzDYIw4=";

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
