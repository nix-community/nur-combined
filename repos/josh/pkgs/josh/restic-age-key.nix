{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  age,
  jq,
  rclone,
  restic,
  tinyxxd,
}:
let
  restic-age-key = buildGoModule {
    pname = "restic-age-key";
    version = "0.2.0";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "restic-age-key";
      rev = "v0.2.0";
      hash = "sha256-Z3nOrYkkVDVShbECNhYoVi2L0QKnB9Nuq44h2SsaZ4k=";
    };

    vendorHash = "sha256-cKa3ov/6aiAxnnbQgDjqiNi1NwZhUsjLIzdkMVj6teU=";

    env.CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
    ];

    nativeCheckInputs = [
      age
      jq
      restic
      tinyxxd
    ];

    meta = {
      description = "Use asymmetric age keys instead of a password on your restic repository";
      homepage = "https://github.com/josh/restic-age-key";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "restic-age-key";
    };
  };
in
restic-age-key.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    restic-age-key = finalAttrs.finalPackage;
  in
  {
    ldflags = previousAttrs.ldflags ++ [
      "-X main.Version=${finalAttrs.version}"
      "-X main.AgeProgram=${lib.getExe age}"
      "-X main.RcloneProgram=${lib.getExe rclone}"
    ];

    passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

    passthru.tests = {
      help =
        runCommand "test-restic-age-key-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ restic-age-key ];
          }
          ''
            restic-age-key --help
            touch $out
          '';
    };
  }
)
