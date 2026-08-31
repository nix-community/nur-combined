{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-smart-video-wallpaper-reborn";
  version = "2.14.1";
  src = fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "plasma-smart-video-wallpaper-reborn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+w+Dj+Xcb5tsyX6ejVBfz7bhrtsWtfoLaVUUCN67QiI=";
  };
  postInstall = ''
    mkdir -p $out/share/plasma/wallpapers/luisbocanegra.smart.video.wallpaper.reborn
    cp -r package/* $out/share/plasma/wallpapers/luisbocanegra.smart.video.wallpaper.reborn
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/luisbocanegra/plasma-smart-video-wallpaper-reborn/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Plasma 6 wallpaper plugin to play videos on your Desktop/Lock Screen";
    homepage = "https://store.kde.org/p/2139746";
    license = lib.licenses.gpl2Only;
  };
})
