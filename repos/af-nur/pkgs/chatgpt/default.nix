{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libnotify
, libGL
, libusb1
, libx11
, libxcb
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxkbcommon
, libxrandr
, mesa
, nspr
, nss
, openssl
, pango
, systemd
, xdg-utils
, bubblewrap
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt";
  version = "26.810.41047";

  src = fetchurl {
    url = if stdenv.hostPlatform.isAarch64 then
      "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_arm64.deb"
    else
      "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = if stdenv.hostPlatform.isAarch64 then
      "sha256-mW95PKA5dnb8uc0AIRTJd1XMN0GQfEAPf13c9scMCk4="
    else
      "sha256-eHFfo80Tb/ZwcNqnaBmtrsxbQumYUVWWWWRdzh+/KvM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat
    fontconfig freetype gdk-pixbuf glib gtk3 libdrm libnotify libGL
    libusb1 libx11 libxcb libxcomposite libxdamage libxext libxfixes
    libxkbcommon libxrandr mesa nspr nss openssl pango systemd
  ];

  unpackPhase = "dpkg-deb -x $src .";

  # libqt5/6_shim.so are optional Electron ozone/Qt shims (not pulled in by
  # the deb's own Depends either); the *.musl.node files are musl-prebuilds
  # that are never loaded on glibc systems. None of them are needed at runtime.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/share
    cp -r usr/lib/chatgpt $out/lib/
    cp -r usr/share/* $out/share/
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/lib/chatgpt/codex-launcher $out/bin/chatgpt \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils bubblewrap ]}
  '';

  meta = with lib; {
    description = "ChatGPT desktop app (Codex App) by OpenAI";
    homepage = "https://developers.openai.com/codex/app";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "chatgpt";
    maintainers = [ ];
  };
})
