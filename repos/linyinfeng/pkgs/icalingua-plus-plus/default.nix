{ sources
, stdenv
, lib
, makeWrapper
, electron
, makeDesktopItem
, nodePackages
, imagemagick

  # package customization
, commandLineArgs ? ""
}:

let
  desktopItem = makeDesktopItem {
    name = "icalingua-plus-plus";
    desktopName = "Icalingua++";
    comment = "A Linux client for QQ and more";
    icon = "icalingua-plus-plus";
    exec = "bash -c \"icalingua-plus-plus %u > /dev/null\"";
    categories = [ "Network" ];
  };
in
stdenv.mkDerivation rec {
  inherit (sources.icalingua-plus-plus) pname version src;

  nativeBuildInputs = [
    makeWrapper
    nodePackages.asar
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${electron}/bin/electron" "$out/bin/icalingua-plus-plus" \
      --add-flags "$out/share/icalingua-plus-plus/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    install -D "$src" "$out/share/icalingua-plus-plus/app.asar"
    install -D "${desktopItem}/share/applications/"* \
      --target-directory="$out/share/applications/"

    asar extract-file "$src" dist/electron/static/icons/512x512.png
    icon=512x512.png
    icon_dir="$out/share/icons/hicolor"
    for s in 16 24 32 48 64 128 256 512; do
      size="''${s}x''${s}"
      echo "create icon \"$size\""
      mkdir -p "$icon_dir/$size/apps"
      ${imagemagick}/bin/convert -resize "$size" "$icon" "$icon_dir/$size/apps/icalingua-plus-plus.png"
    done
  '';

  meta = with lib; {
    description = "A Linux client for QQ and more";
    homepage = "https://github.com/icalingua-plus-plus/icalingua-plus-plus";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ yinfeng ];
  };
}
