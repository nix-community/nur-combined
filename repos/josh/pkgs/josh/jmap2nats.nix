{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "jmap2nats";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "jmap2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2FzTBC7FKAf6k1Me1bvT5Nth5ikYnHaM5URCwXCEolw=";
  };

  vendorHash = "sha256-osoKMrdwMTlgOXzTSeDeop7l8UiZqAAYYL5cpCQ1gEo=";

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
    platforms = lib.platforms.all;
  };
})
