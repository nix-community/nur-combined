{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.13.4";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${version}";
    hash = "sha256-I3xFCUS1Z/THiBwSfF6jWU5QztEcGfAUaLz7Om6N/kA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Kkg4EK7N4wxmnbZ7kNcFNR9VCb7gHenohyeZidtJkuE=";

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
