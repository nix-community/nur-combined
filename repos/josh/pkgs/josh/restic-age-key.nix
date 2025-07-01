{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  age,
  jq,
  restic,
  tinyxxd,
}:
buildGoModule (finalAttrs: {
  pname = "restic-age-key";
  version = "0.2.0-unstable-2025-06-29";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-age-key";
    rev = "021cc60645345db9601b99cc01b23ec05d5e5ada";
    hash = "sha256-Z3nOrYkkVDVShbECNhYoVi2L0QKnB9Nuq44h2SsaZ4k=";
  };

  vendorHash = "sha256-cKa3ov/6aiAxnnbQgDjqiNi1NwZhUsjLIzdkMVj6teU=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.AgeBin=${lib.getExe age}"
  ];

  nativeCheckInputs = [
    age
    jq
    restic
    tinyxxd
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help = runCommand "test-restic-age-key-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      restic-age-key --help
      touch $out
    '';
  };

  meta = {
    description = "Use asymmetric age keys instead of a password on your restic repository";
    homepage = "https://github.com/josh/restic-age-key";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "restic-age-key";
  };
})
