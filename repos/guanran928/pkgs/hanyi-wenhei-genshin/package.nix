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
      url = "https://autopatchcn.yuanshen.com/client_app/download/pc_zip/20240816183703_2noMz7rJZAdUZy6J/ScatteredFiles/YuanShen_Data/StreamingAssets/MiHoYoSDKRes/HttpServerResources/font/${type}.ttf";
    };
in
stdenvNoCC.mkDerivation {
  pname = "hanyi-wenhei-genshin";
  version = "5.0.0";

  srcs = [
    (fetchFont "ja-jp" "sha256-eLjN6wvxW2Kt/P166/0Y1sS8QXw+KpXH1fsMNKbC4yg=")
    (fetchFont "zh-cn" "sha256-etDs1jOjKYGjoL+gge3jAFkur/Ug5zEc5o0X9Rn6RqQ=")
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

  meta = {
    description = "Han Yi Wen Hei (汉仪文黑) font, modified by miHoYo";
    homepage = "https://www.hanyi.com.cn/productdetail?id=987";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
