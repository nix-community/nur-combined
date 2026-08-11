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
    # XXX: Replace once git tag is fixed
    # node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    # tag = "v${finalAttrs.version}";
    rev = "7e8be391f6c48abb9de2188e901f75b265bc225a";
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
    mainProgram = "radicle-ci-ambient";
    licenses = [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
