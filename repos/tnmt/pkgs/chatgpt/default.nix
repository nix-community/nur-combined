{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  autoPatchelfHook,
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
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  vulkan-loader,
  xorg,
  xz,
  nix-update-script,
}:

let
  pname = "chatgpt";
  version = "26.901.20858";

  allArchives = {
    x86_64-linux = {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-QqZHfyL0E21iMh7ae0aXp52h62bWHcuFqwQghgoaUiM=";
    };
    aarch64-linux = {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_arm64.deb";
      hash = "sha256-qbbKvHpPOOYueLN7WVAFDToYnUUC3Hym4ShaeJnYdGk=";
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
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    systemd
    vulkan-loader
    xz
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl { inherit (archive) url hash; };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = runtimeDeps;

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

    ln -s $out/lib/chatgpt/ChatGPT $out/bin/chatgpt

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
