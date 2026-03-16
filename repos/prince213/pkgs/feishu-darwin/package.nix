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
        version = "7.61.6";
        src = fetchurl {
          url = "${base}/ee-appcenter/f5dec49c/Feishu-darwin_arm64-7.61.6-signed.dmg";
          hash = "sha256-Fil0s5PbNl9pAnQKozzbvo4MTsFLG3VDi/BDwhkSv2M=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.61.6";
        src = fetchurl {
          url = "${base}/ee-appcenter/0c133ce3/Feishu-darwin_x64-7.61.6-signed.dmg";
          hash = "sha256-aMzNUJBxGLgdwJe8LoKrPZUNl/nK1WsTkfh/AWzc/D8=";
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
