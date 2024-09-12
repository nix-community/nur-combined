{
  lib,
  sources,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.plasma-smart-video-wallpaper-reborn) pname version src;

  postInstall = ''
    mkdir -p $out/share/plasma/wallpapers/luisbocanegra.smart.video.wallpaper.reborn
    cp -r package/* $out/share/plasma/wallpapers/luisbocanegra.smart.video.wallpaper.reborn
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Plasma 6 wallpaper plugin to play videos on your Desktop/Lock Screen";
    homepage = "https://store.kde.org/p/2139746";
    license = licenses.gpl2Only;
  };
}
