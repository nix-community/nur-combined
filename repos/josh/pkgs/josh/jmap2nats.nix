{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "jmap2nats";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "jmap2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IsLn1A+5vH+bcBJmX96ASuQ7kE4TukgypsnqR4n7eoU=";
  };

  vendorHash = "sha256-Eaf+21pHoB1RKwTmtBL/rhRL/WVBvqQ2CYKja873dIc=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help =
      runCommand "test-jmap2nats-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
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
