# default.nix 文件示例，用于使用 nixpkgs 打包 afrog v3.2.2
{ pkgs,fetchFromGitHub, ... }:

# 使用 buildGoModule 函数来构建 Go 语言项目
pkgs.buildGoModule rec {
  # 软件包的名称
  pname = "afrog";
  # 软件包的版本号，与用户指定的标签 v3.2.2 对应
  version = "3.2.2";

  # 定义源代码的获取方式
  src = pkgs.fetchFromGitHub {
    # GitHub 仓库所有者
    owner = "zan8in";
    # GitHub 仓库名称
    repo = "afrog";
    # 对应的版本标签
    rev = "v${version}";
    # 源代码的 SHA256 校验和。
    # ***重要提示***：您需要将此处的占位符替换为正确的哈希值。
    # 初次尝试构建时，运行 'nix-build'，构建会失败并提示正确的哈希值，请将其粘贴到此处。
    sha256 = "sha256-oNE1Em2ZTT8+2x8X+TGaiOPiyKyCjJHjUEJIVLocSqc=";
  };

  # Go 依赖项的 SHA256 校验和 (Go Modules)。
  # 这是为了确保所有外部 Go 依赖项的完整性。
  # ***重要提示***：您需要将此处的占位符替换为正确的哈希值。
  # 初次尝试构建时，运行 'nix-build'，构建会失败并提示正确的哈希值，请将其粘贴到此处。
  # 如果项目在其源代码中包含了 'vendor' 目录，则将此值设置为 null 或 ""。
  vendorHash = "sha256-P6aeUxrACo3HJzwPL4JeoRkXHSdbo7HYkRhqmCJOE1k=";
  doCheck = false;
  # After installation, remove any helper binaries so only `afrog` remains in $out/bin.
  # This ensures the result path only contains the primary `afrog` executable.
  postInstall = ''
    for f in "$out/bin"/*; do
      base=$(basename "$f")
      if [ "$base" != "afrog" ]; then
        rm -v "$f" || true
      fi
    done
  '';
  
  # 元数据 (Metadata)
  meta = with pkgs.lib; {
    description = "afrog 是一款下一代漏洞扫描工具 (A new generation vulnerability scanning tool).";
    homepage = "https://github.com/zan8in/afrog";
    # 根据项目性质，假设其使用 GPL-3.0 许可证，请根据实际情况修改
    license = licenses.mit;
    # 平台支持
    platforms = platforms.all;
    mainProgram = "afrog";
  };
}
