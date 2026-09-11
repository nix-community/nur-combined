{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unhook-firefox";
  version = "1.4";

  extid = "@unhookng";

  src = fetchFromGitHub {
    owner = "TheArchons";
    repo = "unhookng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GjhOEEy3HJKa2y25pg5Go3V63nufXrSWF/KOsCTPEek=";
  };

  patches = [
    ./0001-avoid-home-feed-flash.patch
  ];

  # Network-level home/trending redirect (upstream #8 approach, sync in-memory).
  postPatch = ''
    cp ${./background.js} background.js
  '';

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd . > /dev/null
    zip -qr "$TMPDIR/unhook.xpi" \
      manifest.json \
      popup.html \
      popup.js \
      unhook.js \
      background.js \
      icons
    popd > /dev/null

    install -Dm644 "$TMPDIR/unhook.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/unhook.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/TheArchons/unhookng/releases/tag/v${finalAttrs.version}";
    description = "Unhook NG Firefox add-on — remove YouTube distractions";
    homepage = "https://github.com/TheArchons/unhookng";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
