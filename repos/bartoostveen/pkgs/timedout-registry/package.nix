{
  lib,
  buildGoModule,
  fetchgit,
  nix-update-script,
}:

buildGoModule (_finalAttrs: {
  pname = "timedout-registry";
  version = "0-unstable-2025-12-09";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchgit {
    # no fetchFromForgejo because of the 'firewall'
    url = "https://git.nexy7574.co.uk/nex/go.timedout.uk.git";
    rev = "f85f4de1c5220f09a6917ee1e312382773dabe84";
    hash = "sha256-iyBXf4uHXx190uTakQvvmw1lhMb7eIbaAgEVjhDtKGI=";
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
