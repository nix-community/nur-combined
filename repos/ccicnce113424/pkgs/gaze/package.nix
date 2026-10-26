{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  clang,
  glib,
  gst_all_1,
  onnxruntime,
  opencv,
  pipewire,
  tpm2-tss,
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
  pname = "gaze";
  # Held at 0.3.10 and out of the update job: 0.4.0 panics on every D-Bus
  # configuration write and removed the TPM key pair of an existing store on
  # upgrade (GunduLabs/gaze#851, GunduLabs/gaze#852). Bump it once both are fixed.
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "GunduLabs";
    repo = "gaze";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oN7xPph2jABJ96Lb/9CoBn6Wz47gVMxfuPdkIncjXVA=";
  };

  cargoHash = "sha256-/FlulnYGsthMxxgC7paTTaMnhm7hgltxfmjhUrVXk3I=";

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    # The opencv crate generates its bindings with libclang at build time.
    rustPlatform.bindgenHook
    clang
  ];

  buildInputs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    onnxruntime
    opencv
    tpm2-tss
  ];

  # Two invocations keep gaze-vision's `detection` feature, and with it ONNX
  # Runtime, out of the clients: features are unified across everything a single
  # `cargo build` compiles.
  buildPhase = ''
    runHook preBuild
    cargo build --release --offline -p gazed
    cargo build --release --offline -p gaze-cli -p pam-gaze -p pam-gaze-grosshack
    runHook postBuild
  '';

  # The test suite needs a camera and a running system bus.
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 target/release/gazed $out/bin/gazed
    install -Dm755 target/release/gaze $out/bin/gaze
    install -Dm755 target/release/libpam_gaze.so $out/lib/security/pam_gaze.so
    install -Dm755 target/release/libpam_gaze_grosshack.so $out/lib/security/pam_gaze_grosshack.so
    install -Dm644 packaging/config/config.toml $out/share/gaze/config.toml
    install -Dm644 packaging/config/com.gundulabs.Gaze.conf $out/share/dbus-1/system.d/com.gundulabs.Gaze.conf
    install -Dm644 packaging/config/com.gundulabs.gaze.policy $out/share/polkit-1/actions/com.gundulabs.gaze.policy
    runHook postInstall
  '';

  # `--set` rather than `--prefix`: a second GStreamer build inherited from the
  # session registers the same plugin types again, and the scanner rejects the
  # duplicates. `ort` is built with `load-dynamic`, so the CPU runtime is only
  # ever dlopen()ed and has to be named here.
  postFixup = ''
    wrapProgram $out/bin/gazed \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPluginPath}" \
      --set GAZE_CPU_ORT_PATH "${lib.getLib onnxruntime}/lib/libonnxruntime.so"
    wrapProgram $out/bin/gaze \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPluginPath}"
  '';

  # The GUI and the desktop integrations reuse this source tree and this
  # vendored dependency set.
  passthru = {
    inherit (finalAttrs) cargoDeps;
  };

  meta = {
    description = "Daemon, CLI, and PAM modules for facial authentication on Linux";
    homepage = "https://gaze.gundulabs.com";
    changelog = "https://github.com/GunduLabs/gaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "gaze";
    platforms = lib.platforms.linux;
  };
})
