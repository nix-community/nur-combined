{
  lib,
  fetchurl,
  runCommand,
  appimageTools,
}:

let
  version = "4.1.0-beta.22";
  pname = "vatis";

  src = fetchurl {
    # No versioned URL available; always serves latest
    url = "https://hub.vatis.app/download/linux";
    hash = "sha256-a10ftXmjv6npTWI8JWV8VCtmKY/kpELyWYJP7SfBy0k=";
    name = "vATIS-${version}.AppImage";
  };

  # Since 4.1.0-beta.22 the AppImage payload is DwarFS (uruntime), which
  # appimageTools cannot unpack; its static runtime extracts itself.
  appimageContents = runCommand "${pname}-${version}-extracted" { } ''
    install -m755 ${src} vatis.AppImage
    ./vatis.AppImage --appimage-extract >/dev/null
    mv "$(readlink -f squashfs-root)" $out # uruntime: squashfs-root -> AppDir
  '';
in
# vATIS is a .NET single-file bundle: patchelf/strip shift the payload appended
# to the ELF ("Failure processing application bundle"), so the binary runs
# unmodified in an FHS environment instead.
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraPkgs =
    pkgs: with pkgs; [
      icu
      curl
      zlib
      fontconfig
      libGL
      vulkan-loader
      libx11
      libxcursor
      libxi
      libxrandr
      libice
      libsm
      alsa-lib
      libpulseaudio
    ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/org.vatsim.vatis.png \
      $out/share/icons/hicolor/256x256/apps/org.vatsim.vatis.png
    install -Dm644 ${appimageContents}/org.vatsim.vatis.desktop \
      $out/share/applications/vatis.desktop
    substituteInPlace $out/share/applications/vatis.desktop \
      --replace-fail 'Exec=vATIS' 'Exec=vatis'
  '';

  meta = {
    description = "A next generation ATIS client for the VATSIM network";
    homepage = "https://github.com/vatis-project/vatis";
    downloadPage = "https://hub.vatis.app/download/linux";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vatis";
  };
}
