{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "jmap2nats";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "jmap2nats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eJYg0H7BCXyfG+VlbriawOPwx9F1N2PkhcaLm5QZhis=";
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
