{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "jmap2nats";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "jmap2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nlp2WBc4B28Eg6vuRslrVCzkq3Aw8PLfxw0/kkWyeGI=";
  };

  vendorHash = "sha256-g6wAhRO7T56Wv1rLQzBW6lqoDQ71SMCslzrxj2HLySg=";

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
