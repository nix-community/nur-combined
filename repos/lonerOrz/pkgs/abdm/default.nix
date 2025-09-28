{
  lib,
  stdenv,
  fetchurl,
  glibc,
  jdk,
  glib,
  zlib,
  alsa-lib,
  libglvnd,
  libXi,
  freetype,
  libXtst,
  libXrender,
  fontconfig,
  libX11,
  libXext,
  makeWrapper,
  gtk3,
  libxkbcommon,
  libXrandr,
  cairo,
  pango,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "abdownloadmanager-bin";
  version = "1.6.14";

  src = fetchurl {
    # 暂时更改为固定的 URL 和 SHA256，直到上游发布新版本
    # url = "https://github.com/amir1376/ab-download-manager/releases/download/v${finalAttrs.version}/ABDownloadManager_${finalAttrs.version}_linux_x64.tar.gz";
    url = "https://github.com/amir1376/ab-download-manager/releases/download/dev-fix-access-denied-error-1/ABDownloadManager_1.0.0-fix-access-denied-error-snapshot_linux_x64.tar.gz";
    sha256 = "sha256-RcUl4H4nO5r6GQxZ0xoVP3e45CInZS+0JS7QdbMK9xc=";
  };

  nativeBuildInputs = [
    makeWrapper
    jdk
  ];

  buildInputs = [
    glibc
    # glib
    zlib
    alsa-lib
    libglvnd
    libXi
    freetype
    libXtst
    libXrender
    fontconfig
    libX11
    libXext

    # GTK 相关依赖
    gtk3
    libxkbcommon
    libXrandr
    cairo
    pango
  ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/ABDownloadManager
    cp -r ABDownloadManager/* $out/opt/ABDownloadManager/

    makeWrapper $out/opt/ABDownloadManager/bin/ABDownloadManager $out/bin/abdm \
      --set GDK_BACKEND x11 \
      --set JAVA_HOME ${jdk} \
      --set JAVA_LIBRARY_PATH \$JAVA_HOME/lib/server \
      --prefix PATH : \$JAVA_HOME/bin \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          glib
          libXext
          libX11
          libXtst
          libXrender
          fontconfig
          freetype
          libXi
          zlib
          alsa-lib
          libglvnd
          gtk3
          libxkbcommon
          libXrandr
          cairo
          pango
        ]
      }

    install -Dm644 $out/opt/ABDownloadManager/lib/ABDownloadManager.png \
      $out/share/pixmaps/ABDownloadManager.png

    mkdir -p $out/share/applications
    cat > $out/share/applications/ABDownloadManager.desktop << EOF
    [Desktop Entry]
    Name=ABDownloadManager
    Exec=abdm
    Type=Application
    Icon=ABDownloadManager
    Comment=A Kotlin based download manager
    Categories=Network;FileTransfer;
    EOF

    runHook postInstall
  '';

  meta = {
    description = "A Kotlin based download manager";
    homepage = "https://github.com/amir1376/ab-download-manager";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    binaryNativeCode = true;
  };
})
