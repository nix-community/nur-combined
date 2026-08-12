{
  lib,
  fetchFromRadicle,
  rustPlatform,
  installShellFiles,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radicle-ci-ambient";
  version = "0.21.1";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z35CgFVYCKpqqDtJMzk8dyE6dViS6"; # radicle-ci-ambient
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "v${finalAttrs.version}";
    hash = "sha256-PrCcvbGvZKjvCHkUDpCEhPjTJcboCA/DxWQTiqYvLyE=";
  };

  cargoHash = "sha256-xTwlcLbka7liWTfBJ1iQarrxv3egxHjcfW8bgA9WdII=";

  nativeBuildInputs = [ installShellFiles ];
  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  patchPhase = ''
    runHook prePatch

    substituteInPlace build.rs \
      --replace-fail 'VERSION={}@{hash}' 'VERSION={}'

    runHook postPatch
  '';

  postInstall = ''
    installManPage ./radicle-ci-ambient.1
  '';

  meta = {
    description = "Radicle CI adapter for Ambient CI";
    homepage = "https://radicle-ci.liw.fi";
    downloadPage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    changelog = "${finalAttrs.meta.downloadPage}/remotes/${finalAttrs.src.node}/tree/${finalAttrs.src.tag}/NEWS.md";
    mainProgram = "radicle-ci-ambient";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
