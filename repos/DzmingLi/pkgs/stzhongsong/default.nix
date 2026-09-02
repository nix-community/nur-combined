{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "stzhongsong";
  version = "1.0";

  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/stzhongsong-1.0/STZHONGS.ttf";
    hash = "sha256-DQ6LpDb4AyNvoQwnkDMnKEw5GGpufYWeD65CPRHERYM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" "$out/share/fonts/truetype/STZHONGS.ttf"
    runHook postInstall
  '';

  meta = {
    description = "STZhongsong (华文中宋) typeface by SinoType";
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/stzhongsong";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    redistributable = false;
  };
}
