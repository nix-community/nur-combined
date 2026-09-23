{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elan-haptune";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "codgician";
    repo = "elan-haptune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pzcnWRKgPETwbPOMXqVEPnjzVU9bX+PagRhj234QpYk=";
  };

  cargoHash = "sha256-iIG24PMrGZIsLlWPgV3u4vwymjv6qeJTqW27pfVRbHA=";

  strictDeps = true;

  # Unit tests in src/tests.rs are pure offline protocol/state checks.
  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };

    tests.cli-help = runCommand "elan-haptune-cli-help" { } ''
      ${lib.getExe finalAttrs.finalPackage} --help | grep -Fq 'One-shot ELAN2703 haptic touchpad settings'
      ${lib.getExe finalAttrs.finalPackage} --version | grep -Fq 'elan-haptune'
      ${lib.getExe finalAttrs.finalPackage} list --json | grep -Fq '"schema_version":1'
      touch "$out"
    '';
  };

  meta = {
    description = "One-shot settings CLI for ELAN haptic touchpads";
    homepage = "https://github.com/codgician/elan-haptune";
    changelog = "https://github.com/codgician/elan-haptune/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    # Upstream documents Linux x86_64 (software-tested) and aarch64 (encoding target).
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "elan-haptune";
  };
})
