{
  lib,
  stdenv,
  fetchurl,
  dwarfs,
  autoPatchelfHook,
  makeWrapper,
  buildFHSEnv,
  pkgs,
}:

let
  version = "4.0.0-beta.9";
  pname = "xpilot";

  # dwarfs 0.14.0 does not build against this nixpkgs's toolchain
  dwarfs' = (dwarfs.override { fmt = pkgs.fmt_11; }).overrideAttrs (old: {
    env = (old.env or { }) // {
      CXXFLAGS = "${old.env.CXXFLAGS or ""} -include cstring";
    };
  });

  src = fetchurl {
    url = "https://downloads.xpilot.app/artifacts/${version}/linux-x64/xPilot.AppImage";
    hash = "sha256-JPvB2hLg1ez9K2ZfZGpk/WZqXfektG8Uf9I2WiQeOew=";
    name = "xPilot-${version}.AppImage";
  };

  # The AppImage is a type-2 image whose payload is a DwarFS filesystem
  # (not squashfs), so appimageTools.extractType2 cannot unpack it.
  appimageContents = stdenv.mkDerivation {
    name = "${pname}-${version}-extracted";
    inherit src;
    nativeBuildInputs = [ dwarfs' ];
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      dwarfsextract --input="$src" --image-offset=auto --output="$out"
      runHook postInstall
    '';
  };

  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version;

    src = appimageContents;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      zlib
      fontconfig
      openssl
      stdenv.cc.cc.lib # libstdc++
    ];

    dontConfigure = true;
    dontBuild = true;

    # Optional LTTng userspace tracing; not needed at runtime.
    autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/libexec $out/share

      # Self-contained .NET/Avalonia app tree shipped inside the AppImage.
      # The native .so live in usr/lib; usr/libexec/xPilot holds ../../lib
      # relative symlinks to them, so both trees must be preserved.
      cp -r usr/lib $out/lib
      cp -r usr/libexec/xPilot $out/libexec/xPilot

      for size in 256x256 512x512; do
        install -Dm644 usr/share/icons/hicolor/$size/apps/xpilot.png \
          $out/share/icons/hicolor/$size/apps/xpilot.png
      done

      # Desktop file
      install -Dm644 xPilot.desktop $out/share/applications/xpilot.desktop
      substituteInPlace $out/share/applications/xpilot.desktop \
        --replace-fail 'Exec=xPilot' 'Exec=xpilot'

      makeWrapper $out/libexec/xPilot/xPilot $out/bin/xpilot \
        --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
        --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath [
          (lib.getLib pkgs.icu)
          pkgs.libGL
          pkgs.vulkan-loader
          pkgs.fontconfig.lib
          pkgs.openssl
          pkgs.alsa-lib
          pkgs.libpulseaudio
          pkgs.xorg.libX11
          pkgs.xorg.libICE
          pkgs.xorg.libSM
          pkgs.xorg.libXext
          pkgs.xorg.libXcursor
          pkgs.xorg.libXi
          pkgs.xorg.libXrandr
        ]}"

      runHook postInstall
    '';

    meta = {
      description = "Cross-platform X-Plane pilot client for the VATSIM network";
      homepage = "https://xpilot.app";
      downloadPage = "https://xpilot.app";
      license = lib.licenses.gpl3Plus;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "xpilot";
    };
  };
in
# `.downloadcsl` makes the client download the upstream installer AppImage to
# $TMPDIR/xPilot.Installer and execute it with `--csl`. That AppImage starts a
# `#!/bin/bash` AppRun and unpatched glibc binaries, so the client runs inside
# an FHS environment able to execute them.
buildFHSEnv {
  inherit pname version;

  runScript = lib.getExe unwrapped;

  # Libraries the downloaded installer resolves from the FHS /usr/lib, plus
  # the tools its AppRun script uses.
  targetPkgs =
    pkgs: with pkgs; [
      findutils
      zlib
      icu
      fontconfig
      freetype
      openssl
      stdenv.cc.cc.lib
      libGL
      vulkan-loader
      libx11
      libice
      libsm
      libxext
      libxcursor
      libxi
      libxrandr
    ];

  # bwrap sets no_new_privs, so the AppImage runtime cannot FUSE-mount through
  # the setuid fusermount and its unshare fallback fails as well; have it
  # extract to $TMPDIR and run from there instead.
  profile = ''
    export APPIMAGE_EXTRACT_AND_RUN=1
  '';

  # Keep the launched installer running if the client exits first.
  unsharePid = false;

  extraInstallCommands = ''
    cp -r ${unwrapped}/share $out/share
  '';

  passthru = { inherit unwrapped; };

  inherit (unwrapped) meta;
}
