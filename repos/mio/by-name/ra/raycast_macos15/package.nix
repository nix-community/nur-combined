# Vendored from nixpkgs b4955aefefab (2026-08-15). See README.md.
{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "raycast_macos15";
  version = "1.104.24";

  src = fetchurl {
    name = "Raycast.dmg";
    url = "https://releases.raycast.com/releases/${finalAttrs.version}/download?build=arm";
    hash = "sha256-kn9bZYSeASKj23NYiWX76OIRXCTonAbUCATyYhPdGgo=";
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Raycast.app";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/Raycast.app"
    cp -R . "$out/Applications/Raycast.app"
    mkdir -p "$out/bin"
    ln -s "$out/Applications/Raycast.app/Contents/MacOS/Raycast" "$out/bin/raycast"

    runHook postInstall
  '';

  meta = {
    description = "Control your tools with a few keystrokes (Raycast v1 for macOS 15 and earlier)";
    homepage = "https://raycast.app/";
    license = lib.licenses.unfree;
    mainProgram = "raycast";
    maintainers = with lib.maintainers; [
      lovesegfault
      stepbrobd
      _4evy
      jakecleary
    ];
    platforms = [
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
