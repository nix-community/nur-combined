{
  gaze,
  lib,
  stdenvNoCC,
}:

let
  uuid = "gaze@gundulabs.com";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gaze-cinnamon-extension";

  # The extension ships files from the daemon's source tree and follows its version.
  inherit (gaze) src version;

  strictDeps = true;
  __structuredAttrs = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    extension=$out/share/cinnamon/extensions/${uuid}
    install -Dm644 integrations/cinnamon/metadata.json -t "$extension"
    install -Dm644 integrations/cinnamon/extension.js -t "$extension"
    install -Dm644 integrations/cinnamon/settings-schema.json -t "$extension"

    runHook postInstall
  '';

  passthru.extensionUuid = uuid;

  meta = {
    description = "Cinnamon Spices extension for Gaze facial authentication";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
