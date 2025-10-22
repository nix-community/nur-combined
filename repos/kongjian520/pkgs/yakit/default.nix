# 定义一个 Nix 包函数
# 它接受一个属性集作为参数，Nixpkgs 会在调用时自动提供这些属性，
# 例如 lib, appimageTools, fetchurl。
{
  lib,
  appimageTools,
  fetchurl,
  writeText, # AppImage 打包通常需要 writeText 来生成 .desktop 文件，在此处也显式列出
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

  # 创建一个 .desktop 文件用于应用程序启动器和菜单集成
  # 这个文件将通过 yakitDesktop 属性被 appimageTools.wrapType2 自动安装。
  yakitDesktop = writeText "${pname}.desktop" ''
    [Desktop Entry]
    # 应用程序名称
    Name=Yakit
    # 应用程序描述/注释
    Comment=实战化攻防安全测试平台
    # 执行命令，这里使用 pname，它会被 appimageTools.wrapType2 替换为实际的启动脚本
    Exec=${pname}
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
  # 继承 let 块中定义的属性
  inherit pname version src yakitDesktop;
  # 完整的包名，包含版本号
  name = "${pname}-${version}";

  # 额外的安装命令：
  # 移除之前导致构建失败的 substituteInPlace 命令，因为它试图修改一个不存在的文件。
  # 你的自定义 yakitDesktop 文件应该已经被 appimageTools 自动安装到 $out/share/applications/。
  extraInstallCommands = "";

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
    maintainers = [ ];
    # 支持的平台，此处仅支持 64 位 Linux
    platforms = [ "x86_64-linux" ];
    # 最终安装到环境中的主程序名称
    mainProgram = "yakit";
  };
}