# EPD-Dashboard 服务端（epd-food-server）：家庭食品存储看板。
# 上游（本机自研仓库 zhyiheihei/EPD-Dashboard）自带 flake 打包，但 zhyi-packages
# 需要独立于上游 flake 的纯 nixpkgs 表达；源码结构随上游部署模块约定的
# server/ 布局，直接以 PYTHONPATH 方式打包源码目录（纯 Python，无 wheel），
# 依赖由 withPackages 的 python 环境提供（fastapi/uvicorn/psycopg/pillow/bleak）。
# version 固定 0.1.0（自研私有服务，_sources 的 version 是 commit hash，仅作 src 引用）
{
  lib,
  stdenv,
  makeWrapper,
  python3,
  sources,
}:
let
  pythonEnv = python3.withPackages (ps:
    with ps; [
      fastapi
      uvicorn
      psycopg
      pillow
      bleak
    ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "epd-food-server";
  version = "0.1.0";

  src = sources.epd-food-server.src;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    # WebUI 静态资源随 epd_food_server/static 一起拷入（api/__init__.py 按相对路径查找）
    cp -r server/epd_food_server $out/lib/epd_food_server
    find $out/lib -name '__pycache__' -type d -exec rm -rf {} +
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/epd-food-server \
      --set PYTHONPATH "$out/lib" \
      --add-flags "-m epd_food_server"
    runHook postInstall
  '';

  # 运行期通过 fontconfig 找系统字体（部署模块会显式传 EPD_FOOD_FONT_PATH）
  meta = {
    description = "家庭食品存储看板服务端（REST API + PostgreSQL + BLE 推送）";
    homepage = "https://github.com/zhyiheihei/EPD-Dashboard";
    license = lib.licenses.unfree;
    maintainers = [ ];
    mainProgram = "epd-food-server";
    platforms = lib.platforms.linux;
  };
})
