{
  lib,
  fetchFromRadicle,
  rustPlatform,
  installShellFiles,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rad-ci";
  version = "0.10.0";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z6QuhJTtgFCZGyQZhRMZmZKJ3SVG"; # rad-ci
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pfz8nvb7l2791Z4m/ogRtbDppu0/w4rGeCswY2JKGvI=";
  };

  cargoHash = "sha256-/Yrga3yEGxND4yb8IXW1PwpwO+m32AmazB6tOnFtqzc=";

  nativeBuildInputs = [ installShellFiles ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  postInstall = ''
    installManPage ./rad-ci.1
  '';

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
