{
  # keep-sorted start
  fetchFromGitHub,
  git,
  lib,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "droast";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "immanuwell";
    repo = "dockerfile-roast";
    tag = finalAttrs.version;
    hash = "sha256-K5QrUwGVt8x5yF/dBPUmfpLy8lGmv3CZrDGxn83upfc=";
  };

  cargoHash = "sha256-bFG4/c294XQ9oFUPtF8A/dKIOjj1WDK3s7nEHeuDLIU=";

  # Discovery tests expect .gitignore rules, which the ignore crate applies only
  # inside a Git repository.
  nativeCheckInputs = [git];
  preCheck = ''
    git init --quiet
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/droast --version | grep -F ${finalAttrs.version}
    runHook postInstallCheck
  '';

  meta = {
    # keep-sorted start
    description = "Dockerfile linter with opinionated, roasting messages";
    homepage = "https://github.com/immanuwell/dockerfile-roast";
    license = lib.licenses.mit;
    mainProgram = "droast";
    # keep-sorted end
  };
})
