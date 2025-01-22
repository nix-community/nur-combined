{
  lib,
  fetchurl,
  stdenvNoCC,
}:
let
  # https://blog.amarea.cn/archives/genshin-windows-cn.html
  fetchFont =
    type: hash:
    fetchurl {
      inherit hash;
      url = "https://autopatchcn.yuanshen.com/client_app/download/pc_zip/20241219110613_vK9mgN3GmQ2Uhp3H/ScatteredFiles/YuanShen_Data/StreamingAssets/MiHoYoSDKRes/HttpServerResources/font/${type}.ttf";
    };
in
stdenvNoCC.mkDerivation {
  pname = "hanyi-wenhei-genshin";
  version = "5.3.0";

  srcs = [
    (fetchFont "ja-jp" "sha256-E1om8ECypwuAjFaZouE1ivaG0UhpYlcNzMRwCPQ5Z6k=")
    (fetchFont "zh-cn" "sha256-SVKzuEAowuMXRyHvxdVNUGIxutEdI8A6QoBT2sRgdpE=")
  ];

  sourceRoot = ".";
  unpackCmd = ''
    ttfName=$(basename $(stripHash $curSrc))
    cp $curSrc ./$ttfName
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 zh-cn.ttf $out/share/fonts/truetype/zh-cn.ttf
    install -Dm644 ja-jp.ttf $out/share/fonts/truetype/ja-jp.ttf

    runHook postInstall
  '';

  passthru.updateScript = ./update.py;

  meta = {
    description = "Han Yi Wen Hei (汉仪文黑) font, modified by miHoYo";
    homepage = "https://www.hanyi.com.cn/productdetail?id=987";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
