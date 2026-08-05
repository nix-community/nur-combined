# Packaging adapted from https://github.com/nobbmaestro/wine-stable-nix
# (package.nix). Prebuilt binaries from Gcenx's WineHQ macOS builds:
# https://github.com/Gcenx/macOS_Wine_builds
#
# Prefixed gcenx-* so these are not confused with nixpkgs wine* (Linux source
# builds; Darwin unsupported on nixpkgs-unstable).
{
  lib,
  stdenvNoCC,
  fetchurl,
  channel,
  version,
  hash,
  appName,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gcenx-wine-${channel}";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Gcenx/macOS_Wine_builds/releases/download/${finalAttrs.version}/wine-${channel}-${finalAttrs.version}-osx64.tar.xz";
    inherit hash;
  };

  sourceRoot = appName;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  # Avoid rewriting signed Mach-O binaries in the .app bundle.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R . "$out/Applications/${appName}"

    for f in "$out/Applications/${appName}/Contents/Resources/wine/bin/"*; do
      ln -s "$f" "$out/bin/$(basename "$f")"
    done

    runHook postInstall
  '';

  meta = {
    description = "Wine ${channel} for macOS (Gcenx / WineHQ prebuilt)";
    homepage = "https://github.com/Gcenx/macOS_Wine_builds";
    downloadPage = "https://github.com/Gcenx/macOS_Wine_builds/releases";
    license = lib.licenses.lgpl21Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.darwin;
    mainProgram = "wine";
    longDescription = ''
      Prebuilt Wine.app from Gcenx's macOS WineHQ packages
      (https://github.com/Gcenx/macOS_Wine_builds). Runs under Rosetta 2 on Apple
      Silicon. Packaging layout adapted from
      https://github.com/nobbmaestro/wine-stable-nix. Requires GStreamer.framework
      for some media features (see upstream README).
    '';
  };
})
