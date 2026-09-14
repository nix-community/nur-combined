{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-wallpaper-carousel";
  version = "0.8.4-unstable-2026-08-20";

  src = fetchFromGitHub {
    owner = "motor-dev";
    repo = "wallpaperCarousel";
    rev = "761ecd1b7f347beee9f17909f8334d987c935a1a";
    hash = "sha256-/LoehTfSeeqkgIXw46Ll/PrxeEDhg4RZI5BXib6yEnI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell plugin to browse and pick wallpapers with a fullscreen skewed carousel overlay";
    homepage = "https://github.com/motor-dev/wallpaperCarousel";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
