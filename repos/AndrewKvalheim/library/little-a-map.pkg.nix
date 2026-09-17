{ fetchFromCodeberg
, lib
, nix-update-script
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
  version = "0.13.12";
  meta = {
    description = "Compositor of player-created Minecraft map items";
    homepage = "https://codeberg.org/AndrewKvalheim/little-a-map";
    license = licenses.gpl3;
    mainProgram = "little-a-map";
  };

  passthru.updateScript = nix-update-script { };

  src = fetchFromCodeberg {
    owner = "AndrewKvalheim";
    repo = "little-a-map";
    rev = "refs/tags/v${little-a-map.version}";
    hash = "sha256-yXjm63saNStsvilkvIcs5q7MExmVvQ2goDgznNvzyDU=";
  };

  cargoHash = "sha256-Jabyrtl3JPHz/aQxt3wljI9VtkW2FsLHvf/u3+Cera4=";

  nativeBuildInputs = [ cmake ];

  preCheck = ''
    export TEST_OUTPUT_PATH="$TMPDIR"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
