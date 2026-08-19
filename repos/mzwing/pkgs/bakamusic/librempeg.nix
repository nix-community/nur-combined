# Build pinned LibreMPEG with its AC-4 decoder and shared libraries for BakaMusic's libmpv runtime.
{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  nasm,
}: let
  pins = (lib.importJSON ./pins.json).mpvRuntime.librempeg;
in
  stdenv.mkDerivation {
    pname = "librempeg";
    version = "0-unstable-${lib.substring 0 10 pins.commit}";

    src = fetchurl {
      url = "https://github.com/librempeg/librempeg/archive/${pins.commit}.tar.gz";
      hash = pins.hash;
    };

    nativeBuildInputs =
      [pkg-config]
      ++ lib.optionals stdenv.hostPlatform.isx86 [nasm];

    # Disable autoconf platform and output flag handling.
    configurePlatforms = [];
    setOutputFlags = false;

    configureFlags = [
      "--arch=${stdenv.hostPlatform.parsed.cpu.name}"
      "--target_os=${stdenv.hostPlatform.parsed.kernel.name}"
      # AC-4 licensing.
      "--enable-gpl"
      "--enable-version3"
      "--enable-agpl"
      # Shared library build.
      "--enable-pic"
      "--enable-shared"
      "--disable-static"
      "--enable-runtime-cpudetect"
      # Internal codecs only.
      "--disable-autodetect"
      "--disable-debug"
      "--disable-doc"
      # Build ffprobe only for the AC-4 check.
      "--enable-ffmpeg"
      "--enable-ffprobe"
      "--disable-ffplay"
      "--disable-htmlpages"
      "--disable-manpages"
      "--disable-podpages"
      "--disable-txtpages"
      # Make the installed probe find its libraries.
      "--enable-rpath"
    ];

    enableParallelBuilding = true;

    # Install licenses for bundled runtime consumers.
    postInstall = ''
      mkdir -p $out/share/licenses/librempeg
      cp COPYING.AGPLv3 COPYING.GPLv3 LICENSE.md $out/share/licenses/librempeg/
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      # Verify AC-4 support.
      $out/bin/ffprobe -hide_banner -decoders | grep -w ac4

      runHook postInstallCheck
    '';

    meta = {
      description = "FFmpeg fork with additional decoders (notably AC-4), used as BakaMusic's media backend";
      homepage = "https://github.com/librempeg/librempeg";
      license = lib.licenses.agpl3Plus;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
