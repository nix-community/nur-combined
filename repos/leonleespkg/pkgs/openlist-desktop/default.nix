{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  lib,
  gtk3,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  dbus,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  glib-networking,
  libayatana-appindicator,
  librsvg,
  rclone,
  fuse3,
  which,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openlist-desktop";
  version = "0.9.1";

  src = fetchurl {
    url = "https://github.com/OpenListTeam/OpenList-Desktop/releases/download/v0.9.1/OpenList-Desktop_0.9.1_amd64.deb";
    hash = "sha256-2VkbjClwqK1cKuHVCHNUWyYMy6GsR/vFrRly0DgkJTQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    dbus
    webkitgtk_4_1
    libsoup_3
    openssl
    glib-networking
    libayatana-appindicator
    librsvg
  ];

  runtimeDependencies = [ libayatana-appindicator ];

  dontBuild = true;
  dontConfigure = true;
  # Only wrap the GTK/Tauri frontend. The bundled OpenList core is a Go
  # sidecar looked up next to current_exe().
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mv usr/* $out
    substituteInPlace $out/share/applications/OpenList-Desktop.desktop \
      --replace-fail 'Exec=openlist-desktop' "Exec=$out/bin/openlist-desktop"
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          rclone
          fuse3
          which
          xdg-utils
        ]
      }
    )
    wrapGApp $out/bin/openlist-desktop
  '';

  meta = with lib; {
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    description = "Desktop application for managing OpenList and Rclone mounts";
    homepage = "https://github.com/OpenListTeam/OpenList-Desktop";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "openlist-desktop";
  };
})
