{
  lib,
  stdenv,

  sources,
  version,

  meson,
  ninja,
  pkg-config,

  bluez,
  dbus,
  fdk_aac,
  glib,
  ldacbt,
  libfreeaptx,
  liblc3,
  liblhdcv5,
  libopus,
  libusb1,
  sbc,
}:

let
  # Keep in sync with the shared_library() calls in spa/plugins/bluez5/meson.build.
  # Only these targets are built; the rest of PipeWire is never compiled.
  bluez5Plugins = [
    "libspa-bluez5.so"
    "libspa-codec-bluez5-aac.so"
    "libspa-codec-bluez5-aptx.so"
    "libspa-codec-bluez5-faststream.so"
    "libspa-codec-bluez5-g722.so"
    "libspa-codec-bluez5-hfp-cvsd.so"
    "libspa-codec-bluez5-hfp-lc3-a127.so"
    "libspa-codec-bluez5-hfp-lc3-swb.so"
    "libspa-codec-bluez5-hfp-msbc.so"
    "libspa-codec-bluez5-lc3.so"
    "libspa-codec-bluez5-ldac.so"
    "libspa-codec-bluez5-lhdc.so"
    "libspa-codec-bluez5-opus.so"
    "libspa-codec-bluez5-opus-g.so"
    "libspa-codec-bluez5-sbc.so"
  ];
in
stdenv.mkDerivation (_finalAttrs: {
  inherit (sources) pname src;
  inherit version;

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    glib # gdbus-codegen, for the org.bluez D-Bus interface
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bluez
    dbus
    fdk_aac
    glib
    ldacbt
    libfreeaptx
    liblc3
    liblhdcv5
    libopus
    libusb1
    sbc
  ];

  # Feature set of the AUR pipewire-bluez5-lhdc-git package: bluez5 and its
  # codecs are turned on explicitly (only `auto` features would be resolved
  # from what happens to be in the closure otherwise), everything else off.
  mesonAutoFeatures = "disabled";

  mesonFlags = [
    (lib.mesonEnable "alsa" false)
    (lib.mesonEnable "bluez5" true)
    (lib.mesonEnable "bluez5-backend-hfp-native" true)
    (lib.mesonEnable "bluez5-backend-hsp-native" true)
    (lib.mesonEnable "bluez5-backend-hsphfpd" true)
    (lib.mesonEnable "bluez5-backend-ofono" true)
    (lib.mesonEnable "bluez5-codec-aac" true)
    (lib.mesonEnable "bluez5-codec-aptx" true)
    (lib.mesonEnable "bluez5-codec-g722" true)
    (lib.mesonEnable "bluez5-codec-lc3" true)
    (lib.mesonEnable "bluez5-codec-ldac" true)
    (lib.mesonEnable "bluez5-codec-lhdc" true)
    (lib.mesonEnable "bluez5-codec-opus" true)
    (lib.mesonEnable "dbus" true)
    (lib.mesonEnable "docs" false)
    (lib.mesonEnable "echo-cancel-webrtc" false)
    (lib.mesonEnable "examples" false)
    (lib.mesonEnable "installed_tests" false)
    (lib.mesonEnable "jack" false)
    (lib.mesonEnable "libcamera" false)
    (lib.mesonEnable "libusb" true)
    (lib.mesonEnable "man" false)
    (lib.mesonEnable "opus" true)
    (lib.mesonEnable "pipewire-alsa" false)
    (lib.mesonEnable "pipewire-jack" false)
    (lib.mesonEnable "selinux" false)
    (lib.mesonEnable "systemd-system-service" false)
    (lib.mesonEnable "systemd-user-service" false)
    (lib.mesonEnable "tests" false)
    (lib.mesonEnable "udev" false)
    # LC3plus needs a source that is not packaged; the LDAC decoder is not
    # useful for a Bluetooth sink-only setup.
    (lib.mesonEnable "bluez5-codec-lc3plus" false)
    (lib.mesonEnable "bluez5-codec-ldac-dec" false)
    (lib.mesonOption "session-managers" "")
  ];

  # The meson configure phase leaves us in the `build` directory.
  buildPhase = ''
    runHook preBuild
    ninja ${lib.escapeShellArgs (map (p: "spa/plugins/bluez5/${p}") bluez5Plugins)}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 -t "$out/lib/spa-0.2/bluez5" spa/plugins/bluez5/*.so
    # The plugin resolves its quirks database relative to SPA_DATA_DIR, falling
    # back to its own compiled-in data directory, which is this very output.
    # Upstream installs it through meson; the working directory here is the
    # meson build directory, hence the path back into the source tree.
    install -Dm644 -t "$out/share/spa-0.2/bluez5" ../spa/plugins/bluez5/bluez-hardware.conf
    runHook postInstall
  '';

  meta = {
    description = "PipeWire bluez5 SPA plugins with LHDC v5 codec support";
    homepage = "https://pipewire.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
