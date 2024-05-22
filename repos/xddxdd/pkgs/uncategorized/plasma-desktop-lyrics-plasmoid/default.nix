{
  lib,
  sources,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.plasma-desktop-lyrics) pname version src;

  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/ink.chyk.plasmaDesktopLyrics
    cp -r plasmoid/* $out/share/plasma/plasmoids/ink.chyk.plasmaDesktopLyrics
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "KDE Plasma 桌面歌词显示挂件（Plasmoid 组件）";
    homepage = "https://github.com/chiyuki0325/PlasmaDesktopLyrics";
    # Upsteam did not specify license
    license = licenses.unfreeRedistributable;
  };
}
