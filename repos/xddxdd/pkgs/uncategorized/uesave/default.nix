{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uesave";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "trumank";
    repo = "uesave-rs";
    tag = "v0.7.1";
    hash = "sha256-lGtRe3AYJ59CwRaDznO6RNqVFCSKJPWVDhj0tnY5xcs=";
  };
  cargoHash = "sha256-6VTy/KHk2mSDfRonxyen4kRMvwBS3uZjsZqMhBJ+boM=";

  doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/trumank/uesave-rs/releases/tag/v${finalAttrs.version}";
    mainProgram = "uesave";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Library for reading and writing Unreal Engine save files (commonly referred to as GVAS)";
    homepage = "https://github.com/trumank/uesave-rs";
    license = lib.licenses.mit;
  };
})
