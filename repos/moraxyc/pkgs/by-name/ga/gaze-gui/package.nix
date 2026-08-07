# SPDX-FileCopyrightText: 2026 Gundu Labs
# SPDX-License-Identifier: GPL-3.0-or-later

# GTK4/Adwaita GUI for Gaze (mirrors packaging/nfpm-gui.yaml).
{
  lib,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  clang,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  opencv,
  openssl,
  pipewire,

  sources,
  source ? sources.gaze,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gaze-gui";
  inherit (source) version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  cargoBuildFlags = [
    "--package"
    "gaze-gui"
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    rustPlatform.bindgenHook
    clang
  ];

  buildInputs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk4
    libadwaita
    opencv
    openssl
  ];

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  doCheck = false;

  postInstall = ''
    install -Dm644 packaging/gui/com.gundulabs.Gaze.desktop $out/share/applications/com.gundulabs.Gaze.desktop
    install -Dm644 packaging/gui/com.gundulabs.Gaze.svg $out/share/icons/hicolor/scalable/apps/com.gundulabs.Gaze.svg
    install -Dm644 packaging/gui/com.gundulabs.Gaze.metainfo.xml $out/share/metainfo/com.gundulabs.Gaze.metainfo.xml
  '';

  preFixup = ''
    gappsWrapperArgs+=(--set GST_PLUGIN_SYSTEM_PATH_1_0 "${
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        pipewire
      ]
    }")
  '';

  meta = {
    description = "GTK4/Adwaita GUI for Gaze facial authentication";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "gaze-gui";
  };
})
