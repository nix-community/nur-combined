{
  gaze,
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
  pipewire,
}:

let
  # GStreamer plugins live in the `lib` output; the default output of these
  # packages is `bin` and carries none.
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    pipewire
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gaze-gui";

  # The GUI shares the daemon's source tree, its vendored dependencies, and its
  # version, the way `oo7-pam` reuses `oo7`.
  inherit (gaze) cargoDeps src version;

  strictDeps = true;
  __structuredAttrs = true;

  # Building a single package keeps gaze-vision's `detection` feature, and with
  # it ONNX Runtime, out of the GUI.
  cargoBuildFlags = [
    "--package"
    "gaze-gui"
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    # The opencv crate generates its bindings with libclang at build time.
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
  ];

  # The test suite needs a camera and a running system bus.
  doCheck = false;

  postInstall = ''
    install -Dm644 packaging/gui/com.gundulabs.Gaze.desktop -t $out/share/applications
    install -Dm644 packaging/gui/com.gundulabs.Gaze.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm644 packaging/gui/com.gundulabs.Gaze.metainfo.xml -t $out/share/metainfo
  '';

  # `--set` rather than `--prefix`; see the comment in `gaze`.
  preFixup = ''
    gappsWrapperArgs+=(--set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPluginPath}")
  '';

  meta = {
    description = "GTK4/Adwaita enrollment and configuration GUI for Gaze";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "gaze-gui";
    platforms = lib.platforms.linux;
  };
})
