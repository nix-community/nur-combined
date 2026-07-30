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
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-age-key";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xXTe3/tkgayeU+84e0wOsKRvNfTC47nQILxLIox247o=";
  };

  vendorHash = "sha256-27VATsznIVkQFK6z95EhOvda8Ty+6sMyXfHKaVfaz2s=";

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

      help = runCommand "test-restic-age-key-help" { nativeBuildInputs = [ restic-age-key ]; } ''
        restic-age-key --help
        touch $out
      '';

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
    description = "Use asymmetric age keys instead of a password on your restic repository";
    homepage = "https://github.com/josh/restic-age-key";
    license = lib.licenses.mit;
    mainProgram = "restic-age-key";
    platforms = lib.platforms.all;
  };
})
