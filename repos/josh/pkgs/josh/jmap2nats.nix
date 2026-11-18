{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "jmap2nats";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "jmap2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m576lySuy7LfwGmBqrW0FaI+RACM0gqNfj3t++6Ci2o=";
  };

  vendorHash = "sha256-CmZub4Or3oCP/SqRjckm3StKY0ZFue7C35xSUXZrqZI=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help = runCommand "test-jmap2nats-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      jmap2nats --help
      touch $out
    '';
  };

  meta = {
    description = "Bridge JMAP email push events to NATS JetStream";
    homepage = "https://github.com/josh/jmap2nats";
    license = lib.licenses.mit;
    mainProgram = "jmap2nats";
  };
})
