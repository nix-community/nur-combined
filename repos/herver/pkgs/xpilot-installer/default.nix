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
  pname = "xpilot-installer";

  # Same toolchain workaround as pkgs/xpilot
  dwarfs' = (dwarfs.override { fmt = pkgs.fmt_11; }).overrideAttrs (old: {
    env = (old.env or { }) // {
      CXXFLAGS = "${old.env.CXXFLAGS or ""} -include cstring";
    };
  });

  # The xPilot client downloads this installer and launches it with
  # `--csl --manifest-url https://downloads.xpilot.app` to install the Bluebell
  # CSL model set. On NixOS the downloaded AppImage cannot start, so package it
  # here to run the CSL installer directly. URL and checksum come from the
  # `installer.linux` entry of the https://downloads.xpilot.app manifest.
  src = fetchurl {
    url = "https://downloads.xpilot.app/artifacts/${version}/linux-x64/xPilot-Installer.AppImage";
    hash = "sha256-eGS1j4bf4+j7sykF88IPub+wB++nEEabKxUg52iD9ao=";
    name = "xPilot-Installer-${version}.AppImage";
  };

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
    # usr/libexec/xPilot-Installer holds ../../lib relative symlinks to the
    # native .so in usr/lib, so both trees must be preserved.
    cp -r usr/lib $out/lib
    cp -r usr/libexec/xPilot-Installer $out/libexec/xPilot-Installer

    for size in 256x256 512x512; do
      install -Dm644 usr/share/icons/hicolor/$size/apps/xpilot-installer.png \
        $out/share/icons/hicolor/$size/apps/xpilot-installer.png
    done

    install -Dm644 xPilot-Installer.desktop $out/share/applications/xpilot-installer.desktop
    substituteInPlace $out/share/applications/xpilot-installer.desktop \
      --replace-fail 'Exec=xPilot-Installer' 'Exec=xpilot-installer'

    # Launch the installer in CSL mode, exactly as the client would, so the
    # Bluebell model-set installer runs. Extra arguments are appended, and the
    # installer's other modes (e.g. --update) remain reachable by overriding.
    makeWrapper $out/libexec/xPilot-Installer/xPilot-Installer $out/bin/xpilot-installer \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--csl --manifest-url https://downloads.xpilot.app" \
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath [
        (lib.getLib pkgs.icu)
        pkgs.libGL
        pkgs.vulkan-loader
        pkgs.fontconfig.lib
        pkgs.openssl
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
    description = "xPilot installer for VATSIM, packaged to run the CSL (Bluebell) model-set installer on NixOS";
    homepage = "https://xpilot.app";
    downloadPage = "https://xpilot.app";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "xpilot-installer";
  };
}
