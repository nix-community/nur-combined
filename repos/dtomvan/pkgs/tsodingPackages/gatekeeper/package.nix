{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule {
  pname = "gatekeeper";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "Gatekeeper";
    rev = "773d4800dcd406f10d7cb23ff770830e53c01dd8";
    hash = "sha256-C5reCItArywe06dCGH651kkRcOjdjLF2TSxP9hz1GDo=";
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
