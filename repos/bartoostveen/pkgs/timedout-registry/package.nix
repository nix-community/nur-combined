{
  lib,
  buildGoModule,
  fetchgit,
  nix-update-script,
}:

buildGoModule (_finalAttrs: {
  pname = "timedout-registry";
  version = "0-unstable-2026-08-26";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchgit {
    # no fetchFromForgejo because of the 'firewall'
    url = "https://git.nexy7574.co.uk/nex/go.timedout.uk.git";
    rev = "2b11ac2d1860f62355eb853cb6848b940b087385";
    hash = "sha256-hXwk3KdUbJNwAJmjHpAVPHBBgri0q4re/b3vYcu1wlU=";
  };

  vendorHash = null;

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=dev" ]; };

  meta = {
    description = "A tiny (0 dependency) Go server that acts as a registry for Golang packages";
    homepage = "https://git.nexy7574.co.uk/nex/go.timedout.uk.git";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "registry";
    platforms = lib.platforms.all;
  };
})
