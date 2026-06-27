{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "nats-static";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nats-static";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gUaLIbE7aBsLDpeSgTOJTzlz5RVuJ3LJPeFIa12dSc4=";
  };

  vendorHash = "sha256-sgodlK/gsDWCyL6/f0ArqFr53cV2eig0tOLFbdzNcYk=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Serve static files from a NATS JetStream object store over HTTP";
    homepage = "https://github.com/josh/nats-static";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "nats-static";
  };
})
