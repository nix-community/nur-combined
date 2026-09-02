{
  lib,
  stdenvNoCC,
  fetchurl,
  libarchive,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omniwm";
  version = "0.6.4";

  src = fetchurl {
    url = "https://github.com/BarutSRB/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
    hash = "sha256-myv1TSDWf1NicAMuBiUXbAbG4DuIl93wJVWNlIM55ec=";
  };

  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [ libarchive ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    bsdtar -xf $src -C $out/Applications

    mkdir -p $out/bin
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/OmniWM $out/bin/OmniWM
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/omniwmctl $out/bin/omniwmctl

    runHook postInstall
  '';

  meta = {
    description = "macOS tiling window manager inspired by Niri and Hyprland";
    longDescription = ''
      OmniWM is a macOS tiling window manager that is developer signed
      and notarized (safe for managed enterprise environments). It
      features Niri-style scrolling columns and Hyprland-style dwindle
      layouts, a quake terminal powered by libghostty, scratchpads,
      overview mode, command palette, and workspace bar.
    '';
    homepage = "https://github.com/BarutSRB/OmniWM";
    changelog = "https://github.com/BarutSRB/OmniWM/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    mainProgram = "OmniWM";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
