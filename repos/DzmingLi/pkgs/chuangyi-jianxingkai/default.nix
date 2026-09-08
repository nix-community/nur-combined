{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "chuangyi-jianxingkai";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/chuangyi-jianxingkai-1.0.1/CTXingKaiSJ.ttf";
    hash = "sha256-fIXL+0j/pb9QA9wBhiYPuYDiPWFK7c2AhvhvX46cbDE=";
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
