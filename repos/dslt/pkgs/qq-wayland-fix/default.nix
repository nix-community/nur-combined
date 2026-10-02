{
  lib,
  stdenv,
  pkg-config,
  glib,
  libpulseaudio,
  libva,
  pipewire,
  libx11,
  wayland,
  wayland-scanner,
  qq,
  sources,
}:

let
  qqSource = {
    x86_64-linux = sources.qq-x86_64;
    aarch64-linux = sources.qq-aarch64;
  }.${stdenv.hostPlatform.system} or (throw "qq-wayland-fix: unsupported platform ${stdenv.hostPlatform.system}");
  # The complete official URL is nvfetcher's tracking key. Extract the public
  # version and build date from its filename, not nixpkgs' older QQ metadata.
  qqRelease = builtins.match "QQ_([0-9.]+)_([0-9]{6})_(amd64|arm64)_[0-9]+\\.deb"
    (builtins.baseNameOf qqSource.version);
  qqDate = builtins.elemAt qqRelease 1;
  qqVersion = assert qqRelease != null;
    "${builtins.elemAt qqRelease 0}-20${builtins.substring 0 2 qqDate}-${builtins.substring 2 2 qqDate}-${builtins.substring 4 2 qqDate}";

  # nvfetcher tracks the branch tip (upstream tags lag behind it) and exposes
  # the UTC commit date.
  waylandFixVersion = "0-unstable-${sources.qq-wayland-fix.date}";

  # LD_PRELOAD shims: QQ's built-in portal + PipeWire capture path, an
  # X11 <-> Wayland clipboard bridge, a wlr-screencopy screenshot fallback, and
  # a Wayland protocol-level fix hiding the share border window and full-screening
  # the screenshot overlay. libpulse and libpipewire are headers-only.
  waylandFix = stdenv.mkDerivation {
    pname = "linuxqq-wayland-fix";
    version = waylandFixVersion;

    src = sources.qq-wayland-fix.src;

    nativeBuildInputs = [
      pkg-config
      wayland-scanner
    ];
    buildInputs = [
      glib
      libpulseaudio
      pipewire
      libx11
      wayland
    ];

    buildPhase = ''
      runHook preBuild
      make libqq-wl-portal.so libqq-clipbridge.so libqq-screenshot.so libqq-borderfix.so \
        VERSION=${waylandFixVersion}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      for lib in libqq-wl-portal libqq-clipbridge libqq-screenshot libqq-borderfix; do
        install -Dm755 "$lib.so" "$out/lib/$lib.so"
      done
      install -Dm644 LICENSE $out/share/licenses/linuxqq-wayland-fix/LICENSE
      runHook postInstall
    '';

    meta = {
      description = "LD_PRELOAD shims that fix Linux QQ's Wayland screen sharing, clipboard, screenshot and share-border behaviour";
      homepage = "https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix";
      license = lib.licenses.mit;
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
  };
  # Plain QQ built from the tracked installer, without the shims. The
  # standalone launcher drives it and injects the shims at launch time, so it
  # must not depend on nixpkgs' QQ whose pinned installer URLs rot.
  qqBase = qq.overrideAttrs (old: {
    version = qqVersion;
    src = qqSource.src;
  });
in
# `qq-wayland-fix` provides the same `qq` command and menu entry as the `qq`
# package, but preloads the Wayland fix into QQ's existing wrapper. Install
# exactly one of the two.
qqBase.overrideAttrs (old: {
  pname = "qq-wayland-fix";

  postFixup = (old.postFixup or "") + ''
    # QQ's resources/app/avsdk/broadcast-core.so dlopens libpipewire-0.3.so.0
    # and libva.so by bare name; NixOS has no global library directory and its
    # ld.so.cache has neither, so both lookups fail and screen sharing never
    # opens a portal (encoding also stays software-only). /run/opengl-driver/lib
    # carries the vendor codec libraries (NVENC/NVDEC/CUDA, AMF, oneVPL) and is
    # appended last so it cannot shadow store libraries. EGL_PLATFORM: with no
    # platform hint glvnd hands eglGetDisplay(EGL_DEFAULT_DISPLAY) to Mesa,
    # which cannot drive the NVIDIA blob and degrades to llvmpipe (share
    # encoding then pegs several cores).
    # makeShellWrapper, not wrapProgram: the binary wrapper from wrapGAppsHook3
    # cannot express the conditional EGL_PLATFORM export (--run is unsupported).
    mv $out/bin/qq $out/bin/.qq-nixpkgs
    makeShellWrapper $out/bin/.qq-nixpkgs $out/bin/qq \
      --inherit-argv0 \
      --prefix LD_PRELOAD : "${waylandFix}/lib/libqq-wl-portal.so:${waylandFix}/lib/libqq-clipbridge.so:${waylandFix}/lib/libqq-screenshot.so:${waylandFix}/lib/libqq-borderfix.so" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libva (lib.getLib pipewire) ]} \
      --suffix LD_LIBRARY_PATH : /run/opengl-driver/lib \
      --set XDG_SESSION_TYPE x11 \
      --set-default MESA_SHADER_CACHE_DISABLE true \
      --run 'if [ -z "''${EGL_PLATFORM:-}" ] && [ -n "''${WAYLAND_DISPLAY:-}" ]; then export EGL_PLATFORM=wayland; fi' \
      --add-flags "--ozone-platform=wayland"
  '';

  passthru = (old.passthru or { }) // {
    inherit qqBase waylandFix;
  };

  meta = old.meta // {
    description = "Tencent QQ with the linuxqq-wayland-fix shims for Wayland screen sharing, clipboard and screenshots";
    longDescription = ''
      Retains the nixpkgs QQ packaging and launcher. Installer URLs are resolved
      from Tencent's official pcConfig.json and fetched through a self-hosted
      signing proxy (https://qqdl.aflare.top) that 302s to a freshly signed
      official URL, because Tencent requires a time-limited signature that
      fetchurl cannot produce; the download is still pinned by a fixed hash, so
      the proxy cannot change the content. Building therefore depends on that
      third-party endpoint.

      The linuxqq-wayland-fix LD_PRELOAD shims keep QQ's UI on X11 while they
      let QQ's broadcast-core use its built-in xdg-desktop-portal ScreenCast +
      PipeWire capture path, bridge the X11 and Wayland clipboards over the
      data-control protocol, emulate X11 root-window screenshots through
      wlr-screencopy, and hide the full-screen share border window while
      full-screening the screenshot overlay.

      Runtime requirements: a Wayland session with XWayland (DISPLAY must be set),
      PipeWire, and a working ScreenCast portal backend such as
      xdg-desktop-portal-gnome, xdg-desktop-portal-kde or xdg-desktop-portal-wlr.
      The clipboard bridge needs a compositor with the data-control protocol;
      screenshots need wlr-screencopy, otherwise they come out black but no
      longer crash. The injected libraries and their MIT license are provided by
      `passthru.waylandFix`.

      `qq-wayland-fix` installs the same `qq` command and menu entry as the `qq`
      package; install only one of the two. The shims hook QQ's internal
      implementation (upstream validated them against QQ 3.2.34-53644), so a
      future QQ update may require them to be re-validated.

      Completely quit any running QQ instance, including its tray icon, before
      starting this variant. Start sharing in QQ and confirm its source dialog;
      then choose the actual screen or window in the desktop portal dialog.
      Should received shares render with stripes, override the package with
      `commandLineArgs = "--use-angle=vulkan"` (or `"swiftshader"` without Vulkan).
    '';
    mainProgram = "qq";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
