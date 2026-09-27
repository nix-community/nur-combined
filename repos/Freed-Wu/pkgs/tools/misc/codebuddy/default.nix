{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "codebuddy";
  version = "2.158.0";

  src =
    {
      x86_64-linux = fetchurl {
        url = "https://acc-1258344699.cos.accelerate.myqcloud.com/@tencent-ai/codebuddy-code/releases/download/${version}/codebuddy-code_Linux_x86_64.tar.gz";
        sha256 = "a0b8bb6ebf59b739b808c13aa55a8a6241318d98cf212b7def2ccfe6ab11360e";
      };
      aarch64-linux = fetchurl {
        url = "https://acc-1258344699.cos.accelerate.myqcloud.com/@tencent-ai/codebuddy-code/releases/download/${version}/codebuddy-code_Linux_arm64.tar.gz";
        sha256 = "8247f34677ff9151b77c304b51ee5c31f2a4a1ba3dc7f44fb50026ef40e8173b";
      };
      x86_64-darwin = fetchurl {
        url = "https://acc-1258344699.cos.accelerate.myqcloud.com/@tencent-ai/codebuddy-code/releases/download/${version}/codebuddy-code_Darwin_x86_64.tar.gz";
        sha256 = "89bf026e41dd4d6fc59f7f8e5fda52c63bf2e0152cd726a17fac0a907c67c766";
      };
      aarch64-darwin = fetchurl {
        url = "https://acc-1258344699.cos.accelerate.myqcloud.com/@tencent-ai/codebuddy-code/releases/download/${version}/codebuddy-code_Darwin_arm64.tar.gz";
        sha256 = "7621835bfed5e0498cdae4840301cbd1a19fb6ccb0276b6ec94d2e88d5096970";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  # 解压并安装二进制文件
  installPhase = ''
    mkdir -p $out/bin
    install -D codebuddy -t $out/bin
  '';

  meta = with lib; {
    homepage = "https://www.codebuddy.cn";
    description = "CodeBuddy Code - 智能代码助手";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "codebuddy";
  };
}
