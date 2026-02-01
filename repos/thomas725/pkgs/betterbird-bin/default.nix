{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  patchelfUnstable,
  wrapGAppsHook3,
  alsa-lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "betterbird-bin";
  version = "140.7.1esr-bb18";

  src = fetchurl {
    url = "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${finalAttrs.version}.en-US.linux-x86_64.tar.xz";
    hash = "sha256-XTzXokiZfzc75nAcotWPdVPMYFDkLVLglyIxwFpcvWk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
  ];

  # Thunderbird uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = [ "--no-clobber-old-sections" ];

  strictDeps = true;

  postPatch = ''
    # Don't download updates from Mozilla directly
    echo 'pref("app.update.auto", "false");' >> defaults/pref/channel-prefs.js
  '';

  installPhase = ''
    runHook preInstall

    appdir="$out/usr/lib/betterbird-bin-${finalAttrs.version}"

    mkdir -p "$appdir"
    cp -r ./* "$appdir"

    mkdir -p "$out/bin"
    ln -s "$appdir/betterbird" "$out/bin/betterbird"

    # wrapThunderbird expects "$out/lib" instead of "$out/usr/lib"
    ln -s "$out/usr/lib" "$out/lib"

    # ---------- Desktop entry ----------
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/betterbird.desktop" <<EOF
    [Desktop Entry]
    Version=1.0
    Name=Betterbird
    GenericName=Mail Client
    Comment=Fine-tuned version of Mozilla Thunderbird (binary build)
    Exec=betterbird %u
    Terminal=false
    Type=Application
    Icon=betterbird
    Categories=Network;Email;Office;
    Keywords=email;mail;news;feed;rss;calendar;
    MimeType=message/rfc822;x-scheme-handler/mailto;application/x-xpinstall;
    StartupWMClass=Betterbird
    StartupNotify=true
    X-GNOME-UsesNotifications=true
    EOF

    # ---------- Icons (symlinks) ----------
    icon_src_dir="$appdir/chrome/icons/default"
    if [ -d "$icon_src_dir" ]; then
      for size in 16 22 24 32 48 64 128 256; do
        icon_src="$icon_src_dir/default''${size}.png"
        if [ -f "$icon_src" ]; then
          icon_dest_dir="$out/share/icons/hicolor/''${size}x''${size}/apps"
          mkdir -p "$icon_dest_dir"
          ln -s "$icon_src" "$icon_dest_dir/betterbird.png"
        fi
      done
      # Optional: SVG, if desktop environment prefers it
      if [ -f "$icon_src_dir/default.svg" ]; then
        icon_dest_dir="$out/share/icons/hicolor/scalable/apps"
        mkdir -p "$icon_dest_dir"
        ln -s "$icon_src_dir/default.svg" "$icon_dest_dir/betterbird.svg"
      fi
    fi

    runHook postInstall
  '';

  meta = with lib; {
    changelog = "https://www.betterbird.net/en-US/betterbird/${finalAttrs.version}/releasenotes/";
    description = "Betterbird binary build – fine-tuned version of Mozilla Thunderbird";
    homepage = "https://www.betterbird.eu";
    mainProgram = "betterbird";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };
})
