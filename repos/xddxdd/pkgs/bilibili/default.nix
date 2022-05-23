{ stdenv
, sources
, electron
, lib
, makeWrapper
, ...
} @ args:

################################################################################
# Mostly based on wechat-uos package from AUR:
# https://aur.archlinux.org/packages/wechat-uos
################################################################################

stdenv.mkDerivation rec {
  inherit (sources.bilibili) pname version src;

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    cp -r usr/share $out/share
    sed -i "s|Exec=.*|Exec=$out/bin/bilibili|" $out/share/applications/*.desktop

    cp -r opt/apps/io.github.msojocs.bilibili/files/bin/app $out/opt

    makeWrapper ${electron}/bin/electron $out/bin/bilibili \
      --argv0 "bilibili" \
      --add-flags "$out/opt/app.asar"
  '';

  meta = with lib; {
    description = "Bilibili desktop client";
    homepage = "https://app.bilibili.com/";
    license = licenses.unfreeRedistributable;
  };
}
