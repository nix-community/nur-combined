{
  lib,
  stdenv,
  pkg-config,
  glib,
  libpulseaudio,
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
  }.${stdenv.hostPlatform.system} or (throw "qq-wlss: unsupported platform ${stdenv.hostPlatform.system}");
  # The complete official URL is nvfetcher's tracking key. Extract the public
  # version and build date from its filename, not nixpkgs' older QQ metadata.
  qqRelease = builtins.match "QQ_([0-9.]+)_([0-9]{6})_(amd64|arm64)_[0-9]+\\.deb"
    (builtins.baseNameOf qqSource.version);
  qqDate = builtins.elemAt qqRelease 1;
  qqVersion = assert qqRelease != null;
    "${builtins.elemAt qqRelease 0}-20${builtins.substring 0 2 qqDate}-${builtins.substring 2 2 qqDate}-${builtins.substring 4 2 qqDate}";

  # nvfetcher tracks the branch tip (upstream tags lag behind it) and exposes
  # the UTC commit date.
  screenshareVersion = "0-unstable-${sources.qq-wlss.date}";

  # LD_PRELOAD shim that enables QQ's own xdg-desktop-portal + PipeWire capture
  # path instead of the X11 screen grabbing path.
  screenshareFix = stdenv.mkDerivation {
    pname = "linuxqq-wayland-screenshare-fix";
    version = screenshareVersion;

    src = sources.qq-wlss.src;

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
      make libqq-wl-portal.so libqq-clipbridge.so VERSION=${screenshareVersion}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 libqq-wl-portal.so $out/lib/libqq-wl-portal.so
      install -Dm755 libqq-clipbridge.so $out/lib/libqq-clipbridge.so
      install -Dm644 LICENSE $out/share/licenses/linuxqq-wayland-screenshare-fix/LICENSE
      runHook postInstall
    '';

    meta = {
      description = "LD_PRELOAD shims that fix Linux QQ's Wayland screen sharing and clipboard integration";
      homepage = "https://github.com/SHORiN-KiWATA/linuxqq-wayland-screenshare-fix";
      license = lib.licenses.mit;
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
  };
in
# `qq-wlss` provides the same `qq` command and menu entry as the `qq` package,
# but preloads the screenshare fix into QQ's existing wrapper. Install exactly
# one of the two.
qq.overrideAttrs (old: {
  pname = "qq-wlss";
  version = qqVersion;
  src = qqSource.src;

  postFixup = (old.postFixup or "") + ''
    wrapProgram $out/bin/qq \
      --prefix LD_PRELOAD : ${screenshareFix}/lib/libqq-wl-portal.so \
      --prefix LD_PRELOAD : ${screenshareFix}/lib/libqq-clipbridge.so \
      --prefix LD_LIBRARY_PATH : ${lib.getLib pipewire}/lib \
      --set XDG_SESSION_TYPE x11 \
      --set-default MESA_SHADER_CACHE_DISABLE true \
      --add-flags "--ozone-platform=wayland"
  '';

  passthru = (old.passthru or { }) // {
    inherit screenshareFix;
  };

  meta = old.meta // {
    description = "Tencent QQ with Wayland screen sharing via its built-in xdg-desktop-portal/PipeWire capture path";
    longDescription = ''
      Retains the nixpkgs QQ packaging and launcher. Installer URLs are resolved
      from Tencent's official pcConfig.json and fetched through a self-hosted
      signing proxy (https://qqdl.aflare.top) that 302s to a freshly signed
      official URL, because Tencent requires a time-limited signature that
      fetchurl cannot produce; the download is still pinned by a fixed hash, so
      the proxy cannot change the content. Building therefore depends on that
      third-party endpoint.

      The linuxqq-wayland-screenshare-fix LD_PRELOAD shims enable QQ's built-in
      xdg-desktop-portal ScreenCast + PipeWire capture path while its UI sees X11,
      and fix clipboard integration under Wayland.

      Runtime requirements: a Wayland session with XWayland (DISPLAY must be set),
      PipeWire, and a working ScreenCast portal backend such as
      xdg-desktop-portal-gnome, xdg-desktop-portal-kde or xdg-desktop-portal-wlr.
      The injected libraries and their MIT license are provided by
      `passthru.screenshareFix`.

      `qq-wlss` installs the same `qq` command and menu entry as the `qq` package;
      install only one of the two. The fix depends on QQ's internal broadcast-core
      implementation (upstream tested against QQ 3.2.34-53644), so a future QQ update
      may require the shim to be re-validated.

      Completely quit any running QQ instance, including its tray icon, before
      starting this variant. Start sharing in QQ and confirm its source dialog;
      then choose the actual screen or window in the desktop portal dialog.
    '';
    mainProgram = "qq";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
