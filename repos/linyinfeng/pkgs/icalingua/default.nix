{ sources
, stdenv
, lib
, makeWrapper
, electron
, makeDesktopItem
, imagemagick
, writeScript
}:

let
  desktopItem = makeDesktopItem {
    name = "icalingua";
    desktopName = "Icalingua";
    comment = "A Linux client for QQ and more";
    icon = "icalingua";
    exec = "icalingua %u";
    categories = "Network";
  };
  icon = sources.icalinguaIcon.src;
in
stdenv.mkDerivation rec {
  inherit (sources.icalingua) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${electron}/bin/electron" "$out/bin/icalingua" \
      --add-flags "$out/share/icalingua/app.asar"

    install -D "$src" "$out/share/icalingua/app.asar"
    install -D "${desktopItem}/share/applications/"* \
      --target-directory="$out/share/applications/"

    icon_dir="$out/share/icons/hicolor"
    for s in 16 24 32 48 64 128 256 512; do
      size="''${s}x''${s}"
      echo "create icon \"$size\""
      mkdir -p "$icon_dir/$size/apps"
      ${imagemagick}/bin/convert -resize "$size" "${icon}" "$icon_dir/$size/apps/icalingua.png"
    done
  '';

  meta = with lib; {
    description = "A Linux client for QQ and more";
    homepage = "https://github.com/Clansty/Icalingua";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
