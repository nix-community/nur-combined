{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.12.6";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "v${version}";
    hash = "sha256-a6+0mYcFo4dakv/VJA/VjHAAu8vHkbVA0vnkmP8keo4=";
  };

  cargoHash = "sha256-GXF+tCB4Vt30oSjfiARi/JL2kI6F/jU0X2Z27H9OoPc=";

  nativeBuildInputs = [ cmake ];

  preCheck = ''
    export TEST_OUTPUT_PATH="$TMPDIR"
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Players can have little a map—if they've surveyed the area in-game. This tool renders a composite of player-created map items with the goal of minimizing external effects on survival gameplay.";
    homepage = "https://codeberg.org/AndrewKvalheim/little-a-map";
    license = lib.licenses.gpl3;
    mainProgram = pname;
  };
}
