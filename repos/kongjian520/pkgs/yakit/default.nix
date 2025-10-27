# 定义一个 Nix 包函数
# 它接受一个属性集作为参数，Nixpkgs 会在调用时自动提供这些属性，
# 例如 lib, appimageTools, fetchurl。
{
  lib,
  appimageTools,
  fetchurl,
  writeText, # 用于生成 .desktop 文件
}:
let
  # 软件版本号
  version = "1.4.4-1017";
  # 软件包名称
  pname = "yakit";
  # 从远程下载 AppImage 文件
  src = fetchurl {
    # 构造下载 URL，从 Yakit 的 GitHub Releases 下载 AppImage
    url = "https://github.com/yaklang/yakit/releases/download/v${version}/Yakit-${version}-linux-amd64.AppImage";
    # 文件的 SHA256 完整性校验哈希
    hash = "sha256-mk++yUjbSDGXRe3AUUUYVPOunBm38Wt6uvZz8Rj9Q2Y=";
  };
  yakitIcon = fetchurl {
    url = "https://raw.githubusercontent.com/yaklang/yakit/f55d9005ab853ebc84403f1cda7f38a271f5c9b6/app/assets/yakitlogo.png";
    hash = "sha256-Q+onckCEc79efrtoycqmYA5YhH9ZR0/N+Leg2+S8VnU=";
    name = "${pname}.png";
  };
  # 创建一个 .desktop 文件内容的 derivation
  # VVVV 修复：改回 yakitDesktop，因为我们不再传递给 wrapType2 的 desktopName 参数 VVVV
  yakitDesktop = writeText "${pname}.desktop" ''
    [Desktop Entry]
    # 应用程序名称
    Name=Yakit
    # 应用程序描述/注释
    Comment=实战化攻防安全测试平台
    # 执行命令，这里使用 pname，它会被 appimageTools.wrapType2 替换为实际的启动脚本
    Exec=${pname} --ozone-platform=wayland
    # 是否在终端中运行
    Terminal=false
    # 应用程序类型
    Type=Application
    # 应用程序分类
    Categories=Development;Security;
    # 应用程序图标名称，它会指向安装目录下的图标文件
    Icon=${pname}
  '';
in
# 使用 appimageTools.wrapType2 函数来封装 AppImage 文件
appimageTools.wrapType2 rec {
  # 继承 let 块中定义的属性 (只保留 wrapType2 真正需要的)
  inherit pname version src;

  # 完整的包名，包含版本号
  name = "${pname}-${version}";

  extraInstallCommands = ''
    # 手动安装 .desktop 文件
    mkdir -p $out/share/applications
    cp ${yakitDesktop} $out/share/applications/

    mkdir -p $out/share/pixmaps
    cp ${yakitIcon} $out/share/pixmaps/${pname}.png
  '';

  # 软件包的元数据
  meta = {
    # 简短描述
    description = "一款实战化攻防安全测试平台，专注于应用层协议安全、Web安全和通用漏洞检测";
    # 软件主页
    homepage = "https://www.yaklang.cn/";
    # 软件下载页面（通常是 Releases 页面）
    downloadPage = "https://github.com/yaklang/yakit/releases";
    # 许可证信息。这里暂定为 AGPLv3。
    license = lib.licenses.agpl3Only;
    # 源代码的来源，此处表明它是包含原生二进制代码的预编译二进制文件。
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    # 维护者列表，当前为空
    maintainers = [ "KongJian520" ];
    # 支持的平台，此处仅支持 64 位 Linux
    platforms = [ "x86_64-linux" ];
    # 最终安装到环境中的主程序名称
    mainProgram = "yakit";
  };
}
