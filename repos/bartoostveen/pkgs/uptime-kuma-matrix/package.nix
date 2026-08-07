{
  lib,
  buildGoModule,
  fetchgit,
  nix-update-script,
}:

buildGoModule (_finalAttrs: {
  pname = "uptime-kuma-matrix";
  version = "0-unstable-2026-08-05";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchgit {
    url = "https://forge.koenoostveen.nl/koen/uptimekuma-matrix.git";
    rev = "5cc7cd54e113d4bc05b75e26e2045b94a33f494a";
    hash = "sha256-Kc6qVpVbc4z9aXzpj7jKppENRXfIuRiwIaOubt0y20w=";
  };

  vendorHash = "sha256-w/ZmNmM9MKnn9UN++ZvVfroRW8KMJHiZddJU0R8gcBE=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "Very simple UptimeKuma webhook receiver for Matrix written in Go";
    homepage = "https://forge.koenoostveen.nl/koen/uptimekuma-matrix.git";
    license = [ ];
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "uptimekuma-matrix";
    platforms = lib.platforms.all;
  };
})
