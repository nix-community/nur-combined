{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.12.7";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "v${version}";
    hash = "sha256-xU920c9wTBmVu/Z8igxFZy9tfMtw0rQV0CRjx1WMhs4=";
  };

  cargoHash = "sha256-TkE9aGf21fx8uYM1VvtX4tj9Oh0EB5tB5pdR1eosnhA=";

  nativeBuildInputs = [ cmake ];

  preCheck = ''
    export TEST_OUTPUT_PATH="$TMPDIR"
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Compositor of player-created Minecraft map items";
    homepage = "https://codeberg.org/AndrewKvalheim/little-a-map";
    license = lib.licenses.gpl3;
    mainProgram = pname;
  };
}
