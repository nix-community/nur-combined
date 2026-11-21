{
  lib,
  buildGoModule,
  fetchFromGitHub,

  age,
  jq,
  rclone,
  restic,
  tinyxxd,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "restic-age-key";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-age-key";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h3GJOTJrY5QegkfGXQo9BY8P8CCqeW5QdocDYbY8+/8=";
  };

  vendorHash = "sha256-I5lp6E4+ji8vjie+k/8m4kgEKnEf3OKyIhrVE40S8pA=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.AgeProgram=${lib.meta.getExe age}"
    "-X main.RcloneProgram=${lib.meta.getExe rclone}"
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

      age-path = runCommand "test-restic-age-key-age-path" { nativeBuildInputs = [ restic-age-key ]; } ''
        restic-age-key --help | grep "${lib.meta.getExe age}"
        touch $out
      '';

      rclone-path =
        runCommand "test-restic-age-key-rclone-path" { nativeBuildInputs = [ restic-age-key ]; }
          ''
            restic-age-key --help | grep "${lib.meta.getExe rclone}"
            touch $out
          '';
    };

  meta = {
    description = "Use asymmetric age keys instead of a password for restic repositories";
    homepage = "https://github.com/josh/restic-age-key";
    license = lib.licenses.mit;
    mainProgram = "restic-age-key";
  };
})
