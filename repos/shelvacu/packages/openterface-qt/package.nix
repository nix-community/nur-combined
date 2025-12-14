{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  runCommand,

  qt6,
  # libsForQt5,
  libusb1,
  pkg-config,
  gst_all_1,
  cmake,
  ffmpeg_6,
  # pkgsStatic,
  libgudev,
  libv4l,
  libxv,
  libxrandr,
  glibc,
  libx11,
  libcap,
  libsysprof-capture,
  v4l-utils,

  # either `systemd` or `eudev` can provide libudev.
  systemd ? null,
  eudev ? null,
  useSystemd ? null,
  libudev ? null,
}@args:
let
  qt = qt6;
  ffmpeg = ffmpeg_6;
  # qt = libsForQt5.qt5;
  ffmpegPrefix = runCommand "openterface-ffmpeg-prefix" { } ''
    mkdir -p $out
    cd $out
    for folder in ${lib.getDev ffmpeg}/* ${lib.getLib ffmpeg}/*; do
      ln --force -s "$folder"
    done
  '';
in
stdenv.mkDerivation (
  finalAttrs:
  let
    args_libudev = args.libudev or null;
    inherit (finalAttrs.finalPackage) useSystemd;
    libudev =
      # if something called libudev was passed explicitly, use that
      if args_libudev != null then
        args_libudev
      # if useSystemd is (non-null and) true, then use systemd
      else if useSystemd == true then
        systemd
      # if useSystemd is (non-null and) false, then use eudev
      else if useSystemd == false then
        eudev
      # if useSystemd is not null, true, or false, that's invalid
      else if useSystemd != null then
        builtins.throw "useSystemd must be true, false, or null"
      # at this point useSystemd is null. Default to systemd iff there is a systemd package
      else if systemd != null then
        systemd
      # otherwise try to use eudev
      else
        eudev;
  in
  {
    pname = "openterface-qt";
    version = "0.5.6";

    src = fetchFromGitHub {
      owner = "TechxArtisanStudio";
      repo = "Openterface_QT";
      rev = finalAttrs.version;
      hash = "sha256-Kt54LvY28dXFOOcTXx2AXijFM8KBya6Uxy6MEKgzO1w=";
    };

    patches = [
      ./stuff.patch
      # ./skip-env-check.patch
      ./fix-cmake-resources.patch
      ./fix-gstreamer-log.patch
      ./no-metainfo.patch
    ];
    postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace-fail /usr/include/ ${lib.getDev glibc}/include/
    '';
    # hardeningDisable = [ "all" ];
    # enableParallelBuilding = false;

    nativeBuildInputs = [
      qt.wrapQtAppsHook
      # qt.qmake
      qt.qtbase
      cmake
      pkg-config
    ];

    buildInputs =
      (with qt; [
        qtbase
        qtmultimedia
        qtserialport
        qtsvg
      ])
      ++ [
        libusb1
        libudev
        libgudev
        libv4l
        libxv
        libxrandr
        libx11
        libcap
        libsysprof-capture
        # (pkgsStatic.ffmpeg-headless.override { withPulse = false; })
        ffmpeg
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
      ];

    # env.FFMPEG_PREFIX = ffmpegPrefix;
    # env.NIX_DEBUG = 7;
    env.NIX_LDFLAGS = "-lX11 -lavdevice -lavformat -lavcodec -lavutil -lavfilter -lswscale";

    # cmakeBuildType = "Debug";
    cmakeFlags = [
      "-DFFMPEG_PREFIX=${ffmpegPrefix}"
      "-DOPENTERFACE_BUILD_STATIC=OFF"
      "-DFFMPEG_LIB_EXT=.so"
      "-DUSE_HWACCEL=OFF"
    ];

    # makeFlags = [ "-d" ];
    
    # buildPhase = ''
    #   mkdir build
    #   cd build
    #   cmake .. -DCMAKE_BUILD_TYPE=Release -DOPENTERFACE_BUILD_STATIC=OFF -DCMAKE_PREFIX_PATH=${qt.qtbase}/lib/cmake/Qt6 -DFFMPEG_LIB_EXT=.so -DUSE_HWACCEL=OFF
    #   make
    # '';

    preInstall = ''
      # make this file empty. It tries to call qt_deploy_runtime_dependencies, and all the usual ways to disable this don't work
      echo > .qt/deploy_*.cmake
    '';

    qtWrapperArgs = lib.escapeShellArgs [
      "--prefix" "PATH" ":" "${v4l-utils}/bin"
    ];

    passthru = {
      useSystemd = args.useSystemd or null;
      inherit libudev;
      updateScript = nix-update-script { };
      withoutSystemd = finalAttrs.finalPackage.overrideAttrs (old: {
        passthru = old.passthru // {
          useSystemd = false;
        };
      });
      withSystemd = finalAttrs.finalPackage.overrideAttrs (old: {
        passthru = old.passthru // {
          useSystemd = true;
        };
      });
    };

    meta = {
      description = "Client software for Openterface Mini-KVM";
      homepage = "https://openterface.com/app/qt/";
      changelog = "https://github.com/TechxArtisanStudio/Openterface_QT/releases";
      license = [ lib.licenses.agpl3Only ];
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      mainProgram = "openterfaceQT";
      platforms = lib.platforms.all;
    };
  }
)
