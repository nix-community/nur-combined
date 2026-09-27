{
  lib,
  stdenvNoCC,
  unzip,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bailian-cli";
  version = "2.0.1";

  # https://bailian-wiki.oss-cn-hangzhou.aliyuncs.com/release/manifest.json
  src =
    {
      x86_64-linux = fetchurl {
        url = "https://bailian-wiki.oss-cn-hangzhou.aliyuncs.com/release/v${version}/bl-${version}-linux-x64.zip";
        sha256 = "a7bb31a5397f3f0702fa396fecc572015bed09b06521d17d5983a30dcbb75d2b";
      };
      aarch64-darwin = fetchurl {
        url = "https://bailian-wiki.oss-cn-hangzhou.aliyuncs.com/release/v${version}/bl-${version}-darwin-arm64.zip";
        sha256 = "672407b50533c62de5b52819229f88e73e5aafc03070fa7458771fc9d5635050";
      };
      x86_64-darwin = fetchurl {
        url = "https://bailian-wiki.oss-cn-hangzhou.aliyuncs.com/release/v${version}/bl-${version}-darwin-x64.zip";
        sha256 = "c0693bec79c4eb044d1fc5e31747bee408eec39200411070a062ecb90d903199";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  # 解压并安装二进制文件
  installPhase = ''
    mkdir -p $out/bin
    unzip $src -d temp
    install -D temp/bl-* -t $out/bin
    mv $out/bin/bl-* $out/bin/bl
  '';

  meta = with lib; {
    homepage = "https://help.aliyun.com/zh/model-studio/developer-reference/getting-started";
    description = "百炼 CLI - 阿里云大模型平台命令行工具";
    license = licenses.unfree; # 假设是非自由许可证，需要确认
    maintainers = with maintainers; [ ]; # 添加维护者
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    mainProgram = "bl";
  };
}
