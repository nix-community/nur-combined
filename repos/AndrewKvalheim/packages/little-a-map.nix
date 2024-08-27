{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "little-a-map";
  version = "0.12.8";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${version}";
    hash = "sha256-ZgD6Bi0m0q+NpMN6qvtMQgBo+6g1zDrMnOsuBaLg+9U=";
  };

  cargoHash = "sha256-JrRX7HOoj5DojOulos0VkdJsjrbUMX1YLwrIg0DR6as=";

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
