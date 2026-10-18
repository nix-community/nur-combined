{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "meat";
  version = "0-unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "boldsoftware";
    repo = "meat";
    rev = "f39f41dfe7b5b37a12b35fdfbaecc7e779855bd3";
    hash = "sha256-fj04sdMiwPxh4F+kBpF5c+YYeKnKCDD9dsIgwAGPoK4=";
  };

  vendorHash = null;

  nativeCheckInputs = [ git ];

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  checkFlags = [ "-short" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help = runCommand "test-meat-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      meat --help 2>&1 | grep "reading diff"
      touch $out
    '';
  };

  meta = {
    description = "Abridge a code diff into a reading diff using an LLM";
    homepage = "https://github.com/boldsoftware/meat";
    license = lib.licenses.asl20;
    mainProgram = "meat";
  };
})
