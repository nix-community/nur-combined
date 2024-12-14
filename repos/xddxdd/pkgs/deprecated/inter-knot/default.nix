{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  imagemagick,
  copyDesktopItems,
  makeDesktopItem,
  # Dependencies
  at-spi2-atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  pango,
}:
stdenv.mkDerivation {
  inherit (sources.inter-knot) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    imagemagick
    copyDesktopItems
  ];

  buildInputs = [
    at-spi2-atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    pango
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/
    chmod +x $out/opt/inter-knot
    makeWrapper $out/opt/inter-knot $out/bin/inter-knot

    mkdir -p $out/share/pixmaps
    convert \
      -depth 24 \
      -define png:compression-filter=1 \
      -define png:compression-level=9 \
      -define png:compression-strategy=2 \
      ${./icon.webp} $out/share/pixmaps/inter-knot.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "inter-knot";
      exec = "inter-knot";
      icon = "inter-knot";
      desktopName = "Inter-Knot";
      comment = "Inter-Knot is a platform for discussing gaming and technology.";
      categories = [ "Network" ];
      extraConfig = {
        "Name[zh_CN]" = "绳网";
        "Name[zh_TW]" = "绳网";
        "Comment[zh_CN]" = "绳网是一个游戏、技术交流平台";
        "Comment[zh_TW]" = "绳网是一个游戏、技术交流平台";
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "绳网是一个游戏、技术交流平台";
    homepage = "https://inot.top";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    knownVulnerabilities = [
      "Service has ceased operation"
    ];
    mainProgram = "inter-knot";
  };
}
