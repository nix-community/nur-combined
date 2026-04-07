{
  feishu,
  fetchurl,
  lib,
  stdenvNoCC,
  undmg,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  sources =
    let
      base = "https://sf3-cn.feishucdn.com/obj";
    in
    {
      # curl 'https://www.feishu.cn/api/package_info?platform=9'
      aarch64-darwin = {
        version = "7.65.8";
        src = fetchurl {
          url = "${base}/ee-appcenter/52008010/Feishu-darwin_arm64-7.65.8-signed.dmg";
          hash = "sha256-Y8GoHwA4oj5+TFeb30tCA9CX4xPWJeG5KkImWlHvarI=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.65.8";
        src = fetchurl {
          url = "${base}/ee-appcenter/1936b3e2/Feishu-darwin_x64-7.65.8-signed.dmg";
          hash = "sha256-fx98tOm1yFcXkdh0Ps/QQkWIHiQzW+8+y0Q0P8wM2EI=";
        };
      };
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (feishu) pname;

  inherit (sources.${system} or (throw "Unsupported system: ${system}")) version src;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Lark.app $out/Applications

    runHook postInstall
  '';

  meta = feishu.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
})
