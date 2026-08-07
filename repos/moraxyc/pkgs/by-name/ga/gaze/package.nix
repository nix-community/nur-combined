{
  lib,
  rustPlatform,
  clang,
  pkg-config,
  makeWrapper,
  glib,
  gst_all_1,
  onnxruntime,
  opencv,
  openssl,
  pipewire,
  tpm2-tss,

  sources,
  source ? sources.gaze,

  withOpenVINO ? false,
}:
let
  ort = if withOpenVINO then onnxruntime.override { openvinoSupport = true; } else onnxruntime;
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    clang
    pkg-config
    makeWrapper
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base

    ort
    opencv
    openssl
    tpm2-tss
  ];

  env = {
    ORT_STRATEGY = "system";
    ORT_LIB_LOCATION = "${lib.getLib ort}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };

  buildPhase = ''
    cargoBuildFlags=(
      --package gaze
    )
    cargoBuildFeatures=(
      ${lib.optionalString withOpenVINO "gaze/openvino"}
    )
    cargoBuildHook

    cargoBuildFlags=(
      --package gaze-cli
      --package pam-gaze
      --package pam-gaze-grosshack
    )
    cargoBuildFeatures=(
      ${lib.optionalString withOpenVINO "gaze-cli/openvino"}
    )
    cargoBuildHook
  '';

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  # Tests require hardware and host services unavailable in the Nix sandbox,
  # notably a camera and the system D-Bus.
  doCheck = false;

  postInstall = ''
    mkdir -p $out/lib/security

    mv $out/lib/libpam_gaze.so \
      $out/lib/security/pam_gaze.so

    mv $out/lib/libpam_gaze_grosshack.so \
      $out/lib/security/pam_gaze_grosshack.so

    install -Dm644 \
      packaging/config/config.toml \
      $out/share/gaze/config.toml

    install -Dm644 \
      packaging/config/com.gundulabs.Gaze.conf \
      $out/share/dbus-1/system.d/com.gundulabs.Gaze.conf

    install -Dm644 \
      packaging/config/com.gundulabs.gaze.policy \
      $out/share/polkit-1/actions/com.gundulabs.gaze.policy
  '';

  postFixup = ''
    for bin in gaze gazed; do
      wrapProgram $out/bin/$bin \
        --set GST_PLUGIN_SYSTEM_PATH_1_0 "${
          lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            pipewire
          ]
        }"
    done
  '';

  passthru = {
    inherit withOpenVINO;
  };

  meta = {
    description = "Facial authentication daemon, CLI, and PAM integration for Linux";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "gaze";
  };
})
