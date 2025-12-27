{ lib, pkgs, stdenv, appimageTools, fetchurl, makeWrapper, ... }:
let
  version = "5.0.0";
  pname = "algermusicplayer";
  algerSrc = {
    "x86_64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-x86_64.AppImage";
      sha256 = "c1e20734937d0a678c222023c1dddee911b97696f996127d1f0b444da2e83649";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-arm64.AppImage";
      sha256 = "9db0e0ef821d7a64c8245c965ccd7a92e165dd3ccc08e02e2b2dbb5f88849917";
    };
  };
  src = algerSrc.${stdenv.hostPlatform.system} or
    (throw "${pname} does not support system ${stdenv.hostPlatform.system}");
  appimageContents = appimageTools.extract { inherit pname version src; };
  runtimeLibs = with pkgs; [
    vips
    glib
    nss
    nspr
    gtk3
    cups
    dbus
    atk
    at-spi2-atk
    libxkbcommon
    alsa-lib
    mesa
    libgbm
    libdrm
    libGL
    libglvnd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    cairo
    pango
    gdk-pixbuf
    expat
    systemd
  ];
in
stdenv.mkDerivation {
  inherit pname version;
  src = appimageContents;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pkgs.vips ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share $out/lib
    cp -r . $out/share/${pname}
    VIPS_LIB="${lib.getLib pkgs.vips}"
    
    vips_cpp=$(find "$VIPS_LIB/lib" -name "libvips-cpp.so*" -type f 2>/dev/null | head -n1)
    vips_so=$(find "$VIPS_LIB/lib" -name "libvips.so*" -type f -not -name "*cpp*" 2>/dev/null | head -n1)
    
    [ -n "$vips_cpp" ] && cp "$vips_cpp" $out/lib/libvips-cpp.so.8.17.3
    [ -n "$vips_so" ] && cp "$vips_so" $out/lib/libvips.so.8
    makeWrapper $out/share/${pname}/AppRun $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath runtimeLibs}" \
      --set-default APPIMAGE_EXTRACT_AND_RUN 1 \
      --unset GIO_EXTRA_MODULES
    install -D algermusicplayer.desktop $out/share/applications/algermusicplayer.desktop
    substituteInPlace $out/share/applications/algermusicplayer.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}" \
      --replace-fail 'Icon=algermusicplayer' "Icon=$out/share/icons/hicolor/512x512/apps/algermusicplayer.png"
    install -D algermusicplayer.png $out/share/icons/hicolor/512x512/apps/algermusicplayer.png
    runHook postInstall
  '';
  meta = {
    description = "Third-party music player for Netease Cloud Music";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = lib.licenses.asl20;
    sourceProvices = with lib.sourceTypes; [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "algermusicplayer";
    platforms = builtins.attrNames algerSrc;
  };
}
