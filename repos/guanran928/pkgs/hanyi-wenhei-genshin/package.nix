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
      url = "https://autopatchcn.yuanshen.com/client_app/download/pc_zip/20241108173401_1jYptYJqdIP6KinO/ScatteredFiles/YuanShen_Data/StreamingAssets/MiHoYoSDKRes/HttpServerResources/font/${type}.ttf";
    };
in
stdenvNoCC.mkDerivation {
  pname = "hanyi-wenhei-genshin";
  version = "5.2.0";

  srcs = [
    (fetchFont "ja-jp" "sha256-MCRYnv4qMO6XXSMswuXTCtmu2ctIwSlF8z36bqvXZEk=")
    (fetchFont "zh-cn" "sha256-KJLPDGhdyP9T2rqQLNwrI9k04wYDe5T6DqwmXx5EDzs=")
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
