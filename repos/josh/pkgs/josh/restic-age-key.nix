{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
  age,
  jq,
  restic,
  rclone,
  tinyxxd,
}:
buildGoModule (finalAttrs: {
  pname = "restic-age-key";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-age-key";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+luDDyUpqEexkhPz6qDtoJ6ytZA7K0sT2DodtGvatoM=";
  };

  vendorHash = "sha256-cKa3ov/6aiAxnnbQgDjqiNi1NwZhUsjLIzdkMVj6teU=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.AgeProgram=${lib.getExe age}"
    "-X main.RcloneProgram=${lib.getExe rclone}"
  ];

  nativeCheckInputs = [
    age
    jq
    restic
    tinyxxd
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests =
    let
      restic-age-key = finalAttrs.finalPackage;
    in
    {
      version = testers.testVersion {
        package = restic-age-key;
        inherit (finalAttrs) version;
      };

      help = runCommand "test-restic-age-key-help" { nativeBuildInputs = [ restic-age-key ]; } ''
        restic-age-key --help
        touch $out
      '';

      age-path = runCommand "test-restic-age-key-age-path" { nativeBuildInputs = [ restic-age-key ]; } ''
        restic-age-key --help | grep "${lib.getExe age}"
        touch $out
      '';

      rclone-path =
        runCommand "test-restic-age-key-rclone-path" { nativeBuildInputs = [ restic-age-key ]; }
          ''
            restic-age-key --help | grep "${lib.getExe rclone}"
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
