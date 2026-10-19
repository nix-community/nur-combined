{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  bun,
  pkgs,
  pkg-config,
  perl,
  openssl,
  sqlite,
  wrapGAppsHook4,
  glib-networking,
  webkitgtk_4_1,
  libayatana-appindicator,
}:

let
  bunSupport = import ./bun-support.nix { inherit pkgs; };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "storyforge";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "LovelessCodes";
    repo = "StoryForge";
    rev = "89fd64ff2ca4c018260bc0538dc2d45aca12114a";
    hash = "sha256-NA7O8oe8eJNMc2f+dr1vxfaklYrXPKE3G9f19psp4Mk=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    cargo-tauri.hook
    bunSupport.hook
    bun
    perl
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

  # Bun 1.3 in the pinned nixpkgs understands the same package records under
  # lockfileVersion 1. Keep the locked resolutions; never regenerate in sandbox.
  postPatch = ''
    substituteInPlace bun.lock --replace-fail '"lockfileVersion": 2' '"lockfileVersion": 1'
    substituteInPlace package.json --replace-fail '"better-auth": "^1.7.7"' \
      '"better-auth": "^1.7.6"'
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
