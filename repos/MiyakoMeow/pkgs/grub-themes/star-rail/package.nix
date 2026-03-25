{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
let
  # 从本地文件读取主题信息
  theme-info = lib.importJSON ./themes.json;

  # 单个主题包构建函数 (原 theme-package.nix 内容内联)
  mkThemePackage =
    pname:
    {
      url,
      sha256,
      tag,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname;
      version = tag;

      src = fetchurl {
        inherit url sha256;
      };

      # 禁用自动解压步骤
      dontUnpack = true;
      dontBuild = true;

      installPhase = ''
        # 解压并解除一层嵌套
        mkdir -p $out
        tar -xzf $src -C $out --strip-components=1

        # 验证主题文件是否存在
        if [ ! -e "$out/theme.txt" ]; then
          echo "ERROR: theme.txt not found in output directory"
          exit 1
        fi
      '';

      meta = with lib; {
        description = "Honkai: Star Rail GRUB theme (${pname})";
        homepage = "https://github.com/voidlhf/StarRailGrubThemes";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
    };

  # 创建所有主题包集合
  theme-packages = lib.mapAttrs mkThemePackage theme-info;

  # 集合的 meta 包，承载统一更新脚本
  metaPkg = stdenvNoCC.mkDerivation rec {
    pname = "star-rail-themes";
    version = "meta";

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontInstall = true;

    passthru.updateScript = {
      group = "grub-themes.star-rail";
      command = [
        "nix-shell"
        "-p"
        "python3"
        "python3Packages.requests"
        "--run"
        "python3 pkgs/grub-themes/star-rail/update.py"
      ];
    };

    meta = with lib; {
      description = "Honkai: Star Rail GRUB themes collection meta package";
      homepage = "https://github.com/voidlhf/StarRailGrubThemes";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
in
# 直接暴露所有主题包，使其可以直接通过 grub-themes.star-rail.acheron 访问
theme-packages
// {
  # 在集合中暴露可执行更新脚本的 meta 包
  meta = metaPkg;
}
