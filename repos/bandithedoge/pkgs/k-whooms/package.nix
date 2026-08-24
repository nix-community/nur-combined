{
  common-updater-scripts,
  curl,
  fetchzip,
  lib,
  pcre2,
  stdenv,
  writeScript,

  autoPatchelfHook,
  cairo,
  expat,
  freetype,
  glib,
  harfbuzz,
  libice,
  libsm,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxext,
  libxkbcommon,
  pango,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "k-whooms";
  version = "2025.03";
  src = fetchzip {
    url = "https://www.hansen-audio.org/download/K-Whooms-${finalAttrs.version}-Linux.tar.gz";
    sha256 = "sha256-S/UTd6qJamvMycFmDqUjx9PDqVGbhqXSHgI48ggVuww=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    cairo
    expat
    freetype
    glib
    harfbuzz
    libice
    libsm
    libx11
    libxcb
    libxcb-cursor
    libxcb-keysyms
    libxext
    libxkbcommon
    pango
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3 $out/share/vst3
    cp -r K-Whooms.vst3 $out/lib/vst3
    cp -r presets $out/share/vst3

    runHook postBuild
  '';

  passthru.updateScript = writeScript "update-k-whooms" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl common-updater-scripts pcre2

    version="$(curl -s https://www.hansen-audio.org | pcre2grep -o1 'Current version: (\d+\.\d+)')"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Get K-Whooms and squeeze the fattest sounds out of it with just a few turns of the controls";
    homepage = "https://www.hansen-audio.org/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
