{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform

  # Dependencies
, cmake
}:

rustPlatform.buildRustPackage (little-a-map: {
  pname = "little-a-map";
  version = "0.13.6";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${little-a-map.version}";
    hash = "sha256-6InYRpSKPOeff2Vu1Q6OWpVFq+OTCuRs9tQsAVUDPsA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8QFWp03wfXZYpIHaciaxXm0CWBQISfI4e6CLT0iKoBQ=";

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
})
