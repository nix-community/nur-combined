# Includes sources from frontend/src-tauri via #[path], so build from the root.
{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  libxkbcommon,
  libx11,
  libxi,
  libxtst,
  libxcb,
  wayland,
  xdotool,
  voice-studio,
}:
rustPlatform.buildRustPackage {
  pname = "voicestudio-desktop-bridge";
  inherit (voice-studio) version src;
  __structuredAttrs = true;

  cargoRoot = "native/desktop-bridge";
  buildAndTestSubdir = "native/desktop-bridge";
  cargoHash = "sha256-C5Pu20V5hp2Yt4/Ijz6ceeFbqJOG8lLacXTDEvHTVy8=";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxkbcommon
    libx11
    libxi
    libxtst
    libxcb
    wayland
    xdotool
  ];

  # Tests drive the real clipboard and input devices.
  doCheck = false;

  meta = {
    inherit (voice-studio.meta)
      homepage
      license
      maintainers
      platforms
      ;
    description = "Native desktop helper for VoiceStudio";
    mainProgram = "voicestudio-desktop-bridge";
  };
}
