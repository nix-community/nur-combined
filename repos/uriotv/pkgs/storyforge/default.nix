{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  bun,
  pkgs,
  pkg-config,
  python3,
  openssl,
  sqlite,
  wrapGAppsHook4,
  glib-networking,
  webkitgtk_4_1,
  libayatana-appindicator,
}:

let
  bunSupport = import ./bun-support.nix { inherit pkgs; };
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "storyforge";
  inherit (source) version;

  src = fetchFromGitHub {
    owner = "LovelessCodes";
    repo = "StoryForge";
    inherit (source) rev hash;
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    cargo-tauri.hook
    bunSupport.hook
    bun
    python3
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
    sqlite
    glib-networking
    webkitgtk_4_1
    libayatana-appindicator
  ];

  bunDeps = bunSupport.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  # A hash-bound, reviewed plan changes compatibility fields only. It never
  # resolves dependencies and fails if upstream sources differ from the plan.
  postPatch = ''
    python3 ${./compatibility.py} --source . --plan ${./compatibility.json}
  '';

  dontUseBunBuild = true;
  dontUseBunCheck = true;
  dontUseBunInstall = true;
  bunInstallFlags = [
    "--linker=hoisted"
    "--frozen-lockfile"
    "--offline"
  ];
  tauriBuildFlags = [
    "--config"
    (builtins.toJSON { bundle.createUpdaterArtifacts = false; })
  ];

  meta = with lib; {
    description = "A modern desktop launcher and mod manager for Vintage Story";
    homepage = "https://github.com/LovelessCodes/StoryForge";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "StoryForge";
  };
})
