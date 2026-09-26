{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  graphite2,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  vulkan-loader,
  xz,
  nix-update-script,
}:

let
  pname = "chatgpt";
  version = "26.924.22138";

  allArchives = {
    x86_64-linux = {
      arch = "amd64";
      hash = "sha256-zjuxqoLM3+MDetov2NGHeW6koNXtAx0OTsitzotwFOc=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-ZXDweMXqJUYc4QOy4x+n3WxecXE2+pI3xwHSLbYrXj8=";
    };
  };

  archive =
    if builtins.hasAttr stdenv.system allArchives then
      allArchives.${stdenv.system}
    else
      throw "chatgpt: unsupported platform ${stdenv.system}";

  runtimeDeps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libGL
    libnotify
    libusb1
    libx11
    libx11.dev
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    mesa
    nspr
    nss
    openssl
    pango
    systemd
    vulkan-loader
    xz
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_${archive.arch}.deb";
    inherit (archive) hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeDeps;

  # ANGLE loads libEGL.so.1 via dlopen, so autoPatchelf can't infer it from DT_NEEDED.
  runtimeDependencies = [ libGL ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;

  autoPatchelfIgnoreMissingDeps = [
    # musl 向け prebuild の native addon (classic-level/node-hid/serialport) は
    # 同ディレクトリの glibc 版が実際に使われるため未解決のままで問題ない。
    "libc.musl-x86_64.so.1"
    # libqt5_shim.so / libqt6_shim.so は KDE 環境検出時にのみ dlopen される
    # オプショナルなプラットフォーム統合用で、GNOME/Hyprland 環境では未使用。
    # Qt5 と Qt6 を同時に buildInputs へ入れると qtbase の setup-hook が
    # "mismatched Qt dependencies" を検出して衝突するため、あえて依存解決せず無視する。
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share/applications $out/share/pixmaps
    cp -r usr/lib/chatgpt $out/lib/

    makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -Dm644 usr/share/pixmaps/chatgpt.png $out/share/pixmaps/chatgpt.png
    install -Dm644 usr/share/applications/chatgpt.desktop $out/share/applications/chatgpt.desktop
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official ChatGPT desktop app by OpenAI, repackaged from the upstream Linux .deb (unofficial Nix packaging)";
    homepage = "https://openai.com/chatgpt/download/";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "chatgpt";
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
    ];
  };
}
