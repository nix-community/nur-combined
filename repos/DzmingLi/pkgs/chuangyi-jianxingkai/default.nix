{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "chuangyi-jianxingkai";
  version = "1.0";

  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/chuangyi-jianxingkai-1.0/CTXingKaiSJ.ttf";
    hash = "sha256-fuZk2XTn+WGX8MiegcJ78FXI+R/5cFTbdJ53GMr25pY=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" "$out/share/fonts/truetype/CTXingKaiSJ.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Chuangyi Jianxingkai (创艺简行楷) typeface";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    redistributable = false;
  };
}
