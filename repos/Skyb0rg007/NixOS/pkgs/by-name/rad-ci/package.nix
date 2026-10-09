{
  lib,
  fetchFromRadicle,
  rustPlatform,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rad-ci";
  version = "0.11.0";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z6QuhJTtgFCZGyQZhRMZmZKJ3SVG"; # rad-ci
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "v${finalAttrs.version}";
    hash = "sha256-0Qq0K8mrFeHxFGwvymWeEsOQ9NmnEQ2zuFvtslEgsMo=";
  };

  cargoHash = "sha256-+Engv2UzmK9HQjVrPV+UCFtQZHhjKdYBBpZwDmkGdWE=";

  nativeBuildInputs = [ installShellFiles ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  postInstall = ''
    installManPage ./rad-ci.1
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Emulate a Radicle CI run locally";
    homepage = "https://radicle-ci.liw.fi";
    downloadPage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    changelog = "${finalAttrs.meta.downloadPage}/remotes/${finalAttrs.src.node}/tree/${finalAttrs.src.tag}/NEWS.md";
    mainProgram = "rad-ci";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
