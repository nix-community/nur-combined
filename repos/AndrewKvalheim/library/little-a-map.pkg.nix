{ fetchFromGitea
, gitUpdater
, lib
, rustPlatform
, versionCheckHook

  # Dependencies
, cmake
}:

let
  inherit (lib) licenses;
in
rustPlatform.buildRustPackage (little-a-map: {
  pname = "little-a-map";
  version = "0.13.10";
  meta = {
    description = "Compositor of player-created Minecraft map items";
    homepage = "https://codeberg.org/AndrewKvalheim/little-a-map";
    license = licenses.gpl3;
    mainProgram = "little-a-map";
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${little-a-map.version}";
    hash = "sha256-HRXsZV6GtIhg0trdxHbGJM9BqYA1wKZW2xbyrIv7yaE=";
  };

  cargoHash = "sha256-KXLZ/FRnwtuutgUI0kiw3fCKJv2dpaxUcVBbonaCJN0=";

  nativeBuildInputs = [ cmake ];

  preCheck = ''
    export TEST_OUTPUT_PATH="$TMPDIR"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
