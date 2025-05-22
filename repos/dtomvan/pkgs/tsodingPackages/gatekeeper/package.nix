{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule {
  pname = "gatekeeper";
  version = "0-unstable-2025-05-10";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "Gatekeeper";
    rev = "faf43d28278b575b58c6e3cb5bdc20f32de461e6";
    hash = "sha256-JdVPLudy0F6fPi8QvqNKTWOatAuEC99dreuiwXAT9uM=";
  };

  vendorHash = "sha256-IEvrGVaYcnR+PxaIc00sw0+TJgoJIi14vihgCkUu8zc=";

  subPackages = [
    "cmd/gatekeeper"
    "cmd/gaslighter"
  ];

  doCheck = false; # no tests

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "The chat bot Zozin does not want you to know about";
    homepage = "https://github.com/tsoding/Gatekeeper";
    license = lib.licenses.mit;
    mainProgram = "gatekeeper";
  };
}
