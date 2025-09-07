{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  # Deps
  gtk2,
  glib,
  gdk-pixbuf,
  curl,
  coreutils,
  ...
}:
let
  # 版本标识符（从URL中提取）
  pkgId = "64ac0526-0589-4ec9-9142-06db38ef3da2";
  version = "V2-64"; # 根据文件名自定义版本号

  # 下载URL
  srcUrl = "http://222.246.130.17:37209/DownloadXml/ClientPkgs/${pkgId}/HN-linux-client${version}.tar.gz";

  # 预计算SHA256哈希（需要替换为实际值）
  sha256 = "0nfalc60n5ksvyd59xrzcya5xim9aa979zyq3p25gxdzyn2ccn4w";
in
stdenv.mkDerivation {
  pname = "hn-linux-client";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    inherit sha256;
  };

  # 自动修补二进制文件
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # 添加运行时依赖，显式声明所有缺失的库
  buildInputs = [
    stdenv.cc.cc.lib # 提供 libstdc++.so.6, libgcc_s.so.1
    gtk2 # 提供 libgtk-x11-2.0.so.0, libgdk-x11-2.0.so.0
    glib # 提供 libgobject-2.0.so.0
    gdk-pixbuf # 提供 libgdk_pixbuf-2.0.so.0
    curl # 提供 libcurl.so.4
    coreutils
  ];

  # 无需配置和构建步骤
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    # 创建输出目录
    mkdir -p $out/ori
    ori_dir="$out/ori"

    # 解压客户端到输出目录
    tar xf $src -C $out/ori --strip-components=1

    # 确保bin目录下存在可执行文件
    if [ ! -f "$out/ori/client" ]; then
      echo "ERROR: client not found in (out)/bin directory"
      exit 1
    fi

    # 为每个原始可执行文件创建包装脚本
    for exe in $(find $out/ori -type f -executable); do
      # 获取文件名（不含路径）
      exe_name=$(basename "$exe")

      # 添加前缀hn-linux-到包装脚本
      wrapper_name="hn-linux-$exe_name"
      wrapper_path="$out/bin/$wrapper_name"
      # 创建更安全的包装脚本
      makeWrapper "$exe" "$wrapper_path" \
        --run 'HN_TEMP_DIR=$(mktemp -d -t hn-client-XXXXXX)' \
        --run "cp -r \"$ori_dir/\"* \"\$HN_TEMP_DIR\"" \
        --run 'cd "$HN_TEMP_DIR"' \
        --add-flags "\$@"

      # 设置包装脚本权限
      chmod +x "$wrapper_path"
    done
  '';

  # 设置环境钩子
  setupHook = ./setup-hook.sh;

  desktopItems =
    let
      pname = "hn-linux-client";
    in
    [
      (makeDesktopItem {
        name = pname;
        desktopName = "China Telecom (HUNAN Campus Net) Linux Client";
        exec = pname;
        comment = "HN Linux Client, for net interface of China Telecom in HUNAN University";
        mimeTypes = [
          "application/network"
        ];
        categories = [ "Network" ];
        terminal = false;
      })
    ];

  meta = with lib; {
    description = "HN Linux Client, for net interface of China Telecom in HUNAN University";
    homepage = "http://222.246.130.17:37209/";
    license = licenses.unfree; # 根据实际许可证调整
    mainProgram = "hn-linux-client";
    platforms = [ "x86_64-linux" ]; # 仅支持64位Linux
    maintainers = [ ];
  };
}
