{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
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

  meta = {
    description = "Bridge JMAP email push events to NATS JetStream";
    homepage = "https://github.com/josh/jmap2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "jmap2nats";
  };
})
