{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildGoModule {
  pname = "go-staticmaps";
  version = "0-unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "go-staticmaps";
    rev = "47d062eaabcee02a9008db85b959e089314bde94";
    hash = "sha256-jnM2GrN4HyVGarnopH0DCmI+Gfh4DLHWZNqiJu0GrwA=";
  };

  patches = [ ./extra-tileproviders.patch ];

  vendorHash = "sha256-NrkwyKcVZ1IJv70CIOXD+GCvFhuKoEPYSi9V4sHrkcs=";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "A go (golang) library and command line tool to render static map images using OpenStreetMap tiles";
    homepage = "https://github.com/flopp/go-staticmaps";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
