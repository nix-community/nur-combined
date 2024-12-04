{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.13.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${version}";
    hash = "sha256-H1vAziHS7ThWgOLDBcMQ9Yb1hYOCNF0kmSUFaoplPaQ=";
  };

  cargoHash = "sha256-kYPlZw75MOvyHLA9bCCj2G4s75LiUomONsMGkNUl1lc=";

  nativeBuildInputs = [ cmake ];

  preCheck = ''
    export TEST_OUTPUT_PATH="$TMPDIR"
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Compositor of player-created Minecraft map items";
    homepage = "https://codeberg.org/AndrewKvalheim/little-a-map";
    license = lib.licenses.gpl3;
    mainProgram = "little-a-map";
  };
}
