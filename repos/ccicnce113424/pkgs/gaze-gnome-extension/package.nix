{
  gaze,
  lib,
  stdenvNoCC,
  glib,
}:

let
  uuid = "gaze@gundulabs.com";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gaze-gnome-extension";

  # The extension ships files from the daemon's source tree and follows its version.
  inherit (gaze) src version;

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [ glib ];

  # The GDM dconf defaults and the `gdm-face` PAM service the extension relies on
  # are written by the NixOS module, not by this package.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    extension=$out/share/gnome-shell/extensions/${uuid}
    install -Dm644 integrations/gnome-shell/metadata.json -t "$extension"
    install -Dm644 integrations/gnome-shell/extension.js -t "$extension"
    install -Dm644 integrations/gnome-shell/prefs.js -t "$extension"
    # GNOME Shell looks the settings schema up inside the extension directory.
    install -Dm644 packaging/config/org.gnome.shell.extensions.gaze.gschema.xml -t "$extension/schemas"
    glib-compile-schemas --strict "$extension/schemas"

    # The GNOME session puts $out/share/gsettings-schemas/$name on
    # XDG_DATA_DIRS, which is what makes `gsettings` and the preferences window
    # find the schema outside a running shell.
    schemadir=$out/share/gsettings-schemas/${finalAttrs.pname}/glib-2.0/schemas
    install -Dm644 packaging/config/org.gnome.shell.extensions.gaze.gschema.xml -t "$schemadir"
    glib-compile-schemas --strict "$schemadir"

    runHook postInstall
  '';

  passthru.extensionUuid = uuid;

  meta = {
    description = "GNOME Shell extension for Gaze facial authentication";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
