{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-data-flypy";
  # Taken from schema.version in flypy.schema.yaml.
  version = "10.26.9";

  # Vendored snapshot of 小鹤音形 (flypy) 鼠须管 data from 小鹤网盘
  # (http://flypy.ysepan.com → 第三方平台挂接文件 → 音形码 →
  # 小鹤音形“鼠须管”for macOS.zip). See ./README.md for details.
  src = ./.;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r share/rime-data $out/share/rime-data
    runHook postInstall
  '';

  meta = {
    description = "小鹤音形 (flypy) Rime schema data for fcitx5-rime and Squirrel";
    homepage = "https://flypy.cc/";
    platforms = lib.platforms.all;
  };
}
