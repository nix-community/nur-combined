{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:

buildGoModule {
  pname = "go-staticmaps";
  version = "0-unstable-2025-06-29";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "go-staticmaps";
    rev = "973b17999e196be69437fe40897af961b4557602";
    hash = "sha256-/dF9JW+Gmf3Y7Nr3J4NfjiQucLQC6v/Lzn7F1yQw158=";
  };

  patches = [ ./extra-tileproviders.patch ];

  vendorHash = "sha256-082d3Ho+kUyvDAE9gRlHdjS3Jy9SSsCn/NZ0HXiKU5g=";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "A go (golang) library and command line tool to render static map images using OpenStreetMap tiles";
    homepage = "https://github.com/flopp/go-staticmaps";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
