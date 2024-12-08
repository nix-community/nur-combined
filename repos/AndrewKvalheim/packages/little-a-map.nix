{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.13.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${version}";
    hash = "sha256-mfYcEpHxGnCLxFpTC6rKY63yKAFZPDJVXecP+5mStJA=";
  };

  cargoHash = "sha256-5CAhcw3GtEXgV6P8aPcJREvE/sddVi8N4fscbRmIFM0=";

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
