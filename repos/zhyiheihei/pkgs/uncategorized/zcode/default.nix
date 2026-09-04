# ZCode: Z.ai (智谱) 官方 AI 编码桌面应用（Agentic Development Environment）。
# 上游不发布 nix 包，从官方 Linux x64 .deb 解包重打包：
#   - /opt/ZCode：Electron 运行时 + app.asar + 内嵌 CLI（resources/glm/zcode.cjs）
#     + 自带 ripgrep/bfs 等工具，全部 ELF 由 autoPatchelfHook 补 rpath；
#   - 图标与 .desktop 原样搬运，Exec 改指 PATH 里的包装脚本。
# 仅登记 x64 deb 源，aarch64 版上游存在但未纳入。
{
  lib,
  stdenv,
  sources,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-core,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libxkbcommon,
  libXtst,
  libxcb,
  nspr,
  nss,
  pango,
  xdg-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "zcode";
  inherit (sources.zcode) version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libuuid
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXrender
    libXScrnSaver
    libxkbcommon
    libXtst
    libxcb
    nspr
    nss
    pango
    xdg-utils
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share
    cp -r opt/ZCode $out/opt/ZCode
    cp -r usr/share/icons $out/share/icons

    substituteInPlace usr/share/applications/zcode.desktop \
      --replace-fail "Exec=/opt/ZCode/zcode" "Exec=zcode"
    install -Dm644 usr/share/applications/zcode.desktop \
      $out/share/applications/zcode.desktop

    # xdg-utils 供 Electron 桌面集成（默认浏览器/剪贴板/MIME 处理）调用。
    makeWrapper $out/opt/ZCode/zcode $out/bin/zcode \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    runHook postInstall
  '';

  meta = {
    description = "Z.ai's official agentic development environment desktop app for GLM models";
    homepage = "https://zcode.z.ai";
    changelog = "https://zcode.z.ai/en/docs/install";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "zcode";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
