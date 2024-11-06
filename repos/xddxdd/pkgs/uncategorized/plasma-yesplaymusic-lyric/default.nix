{
  lib,
  sources,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.plasma-yesplaymusic-lyric) pname version src;

  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.yesplaymusic-lyrics
    cp -r * $out/share/plasma/plasmoids/org.kde.plasma.yesplaymusic-lyrics
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Display YesPlayMusic lyrics on the plasma panel | 在KDE plasma面板中显示YesPlayMusic的歌词";
    homepage = "https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics";
    license = lib.licenses.mit;
  };
}
