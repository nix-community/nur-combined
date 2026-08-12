# LibreMPEG (an FFmpeg fork) built from source at the commit pinned by the
# upstream BakaMusic media-runtime manifest
# (scripts/media-runtime-manifest.json -> mpv.sourceCommits.librempeg, kept
# in ./pins.json by ./update-pins.sh). BakaMusic's libmpv runtime requires
# the AC-4 decoder, which only exists in this fork — FFmpeg proper has no
# ac4dec.c.
#
# The configure flags mirror upstream's runtime build (Zencok/
# mpv-libre-runtime, build/unix/build.sh) with one deliberate difference:
# shared libraries instead of static. Upstream links statically to make a
# self-contained redistribution tarball; under Nix the consumers' rpath
# holds absolute store paths, so static linking buys nothing and only
# complicates the mpv meson link.
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

    # The FFmpeg-family configure script is not autoconf: no --build/--host
    # platforms and no output flag splitting.
    configurePlatforms = [];
    setOutputFlags = false;

    configureFlags = [
      "--arch=${stdenv.hostPlatform.parsed.cpu.name}"
      "--target_os=${stdenv.hostPlatform.parsed.kernel.name}"
      # Licensing flags (upstream uses --enable-agpl for the AC-4 decoder)
      "--enable-gpl"
      "--enable-version3"
      "--enable-agpl"
      # Build flags
      "--enable-pic"
      "--enable-shared"
      "--disable-static"
      "--enable-runtime-cpudetect"
      # No external libraries: the codec box is entirely internal
      "--disable-autodetect"
      "--disable-debug"
      "--disable-doc"
      # Programs: ffprobe only exists for the installCheck AC-4 probe;
      # neither program is shipped in the final package (mirrors upstream,
      # which prunes them from the installed runtime).
      "--enable-ffmpeg"
      "--enable-ffprobe"
      "--disable-ffplay"
      "--disable-htmlpages"
      "--disable-manpages"
      "--disable-podpages"
      "--disable-txtpages"
      # Give the installed programs an rpath to $out/lib so the
      # installCheck probe runs without LD_LIBRARY_PATH.
      "--enable-rpath"
    ];

    enableParallelBuilding = true;

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      # The whole point of the fork: the AC-4 decoder must be present.
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
