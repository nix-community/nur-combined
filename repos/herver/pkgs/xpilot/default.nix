{
  lib,
  stdenv,
  fetchurl,
  dwarfs,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "4.0.0-beta.6";
  pname = "xpilot";

  # dwarfs 0.14.0 does not build against this nixpkgs's toolchain:
  #  - its vendored fbthrift predates fmt 12's API break ('fmt::format' is
  #    not found, 'fmt::join(initializer_list)' is deprecated), so build it
  #    against fmt 11 instead of the default fmt 12;
  #  - its vendored folly headers use std::memcpy/std::memset without
  #    including <cstring>, which recent libstdc++ no longer pulls in
  #    transitively, so force-include <cstring> for every C++ translation
  #    unit (CXX-only, leaving the handful of C sources untouched).
  dwarfs' = (dwarfs.override { fmt = pkgs.fmt_11; }).overrideAttrs (old: {
    env = (old.env or { }) // {
      CXXFLAGS = "${old.env.CXXFLAGS or ""} -include cstring";
    };
  });

  src = fetchurl {
    url = "https://downloads.xpilot.app/artifacts/${version}/linux-x64/xPilot.AppImage";
    hash = "sha256-+5XCYvur2mZfoZ9xpfkKPG8V7IYC+nQqL5uhlnzxr5c=";
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
in
stdenv.mkDerivation {
  inherit pname version;

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

    # Icons (only the client's, not the bundled installer's).
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
}
