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
    url = "https://github.com/yaklang/yakit/releases/download/v${version}/Yakit-${version}-linux-amd64.AppImage";
    hash = "sha256-mk++yUjbSDGXRe3AUUUYVPOunBm38Wt6uvZz8Rj9Q2Y=";
  };

  yakitIcon = fetchurl {
    url = "https://raw.githubusercontent.com/yaklang/yakit/f55d9005ab853ebc84403f1cda7f38a271f5c9b6/app/assets/yakitlogo.png";
    hash = "sha256-Q+onckCEc79efrtoycqmYA5YhH9ZR0/N+Leg2+S8VnU="; 
    name = "${pname}.png";
  };
  # ^^^^ 新增：下载 Logo 文件 ^^^^

  # 创建一个 .desktop 文件内容的 derivation
  yakitDesktop = writeText "${pname}.desktop" ''
    [Desktop Entry]
    # 应用程序名称
    Name=Yakit
    # 应用程序描述/注释
    Comment=实战化攻防安全测试平台
    # Exec 引用的是 $out/bin 目录下的启动脚本
    Exec=${pname}
    # 是否在终端中运行
    Terminal=false
    # 应用程序类型
    Type=Application
    # 应用程序分类
    Categories=Development;Security;
    # 应用程序图标名称，这里引用的是 $out/share/icons/hicolor/256x256/apps/yakit.png
    # 或者 $out/share/pixmaps/yakit.png (此处我们采用 $pname 约定)
    Icon=${pname}
  '';
in
# 使用 appimageTools.wrapType2 函数来封装 AppImage 文件
appimageTools.wrapType2 rec {
  # 继承 let 块中定义的属性
  inherit pname version src;

  # 完整的包名，包含版本号
  name = "${pname}-${version}";

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${yakitDesktop} $out/share/applications/
    
    # VVVV 新增：手动安装 Icon 文件 VVVV
    # 2. 将图标安装到 $out/share/pixmaps/，这是传统的 Linux 图标位置，
    # 并且与 .desktop 文件中的 Icon=${pname} 匹配
    mkdir -p $out/share/pixmaps
    cp ${yakitIcon} $out/share/pixmaps/${pname}.png 

    ln -sf $out/bin/${pname}-${version} $out/bin/${pname}
  '';

  # 软件包的元数据
  meta = {
    description = "一款实战化攻防安全测试平台，专注于应用层协议安全、Web安全和通用漏洞检测";
    homepage = "https://www.yaklang.cn/";
    downloadPage = "https://github.com/yaklang/yakit/releases";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ "KongJian520" ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "yakit";
  };
}