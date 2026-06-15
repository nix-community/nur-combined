{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  wayland,
  libGL,
  mesa,

  # GStreamer
  gst_all_1,
}:

let
  inherit (gst_all_1)
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
    ;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "phonto";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "museslabs";
    repo = "phonto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KyOIph3rz3de3L0ioBOL6sIw6b7PS8wRU34dVWCpTVo=";
  };

  cargoHash = "sha256-LstZPpuzw7KyY8lPfAFgAwSmWika23lnFNIGmIkTDVM=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    wayland
    libGL
    mesa

    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];

  dontWrapGApps = !stdenv.isLinux;

  meta = {
    description = "GPU-accelerated video wallpaper program for wayland compositors and macos";
    homepage = "https://github.com/museslabs/phonto";
    license = lib.licenses.gpl3Plus;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "phonto";
  };
})
