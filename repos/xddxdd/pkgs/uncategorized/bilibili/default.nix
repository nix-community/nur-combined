{
  stdenv,
  sources,
  electron,
  lib,
  makeWrapper,
}:
let
  res = "${sources.bilibili-src.src}/res";
in
stdenv.mkDerivation rec {
  inherit (sources.bilibili) pname version src;

  buildInputs = [ makeWrapper ];

  sourceRoot = ".";

  postInstall = ''
    mkdir -p $out
    cp -r app $out/opt

    install -Dm644 ${res}/bilibili.desktop $out/share/applications/bilibili.desktop
    sed -i "s|Exec=.*|Exec=$out/bin/bilibili|" $out/share/applications/bilibili.desktop

    for FILE in ${res}/icons/*.png; do
      BASENAME=$(basename $FILE)
      SIZE=''${BASENAME%.png}
      install -Dm644 ${res}/icons/$SIZE.png $out/share/icons/hicolor/$SIZE/apps/bilibili.png
    done

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/bilibili \
      --argv0 "bilibili" \
      --add-flags "$out/opt/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Bilibili desktop client";
    homepage = "https://app.bilibili.com/";
    license = lib.licenses.unfreeRedistributable;
  };
}
