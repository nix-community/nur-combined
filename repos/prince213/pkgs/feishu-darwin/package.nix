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
        version = "7.70.10";
        src = fetchurl {
          url = "${base}/ee-appcenter/9451977a/Feishu-darwin_arm64-7.70.10-signed.dmg";
          hash = "sha256-atdoWc2UIqW8cZxonXM4Ckna/NWrRnnxOPSObG1bZww=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.70.10";
        src = fetchurl {
          url = "${base}/ee-appcenter/c2ec64aa/Feishu-darwin_x64-7.70.10-signed.dmg";
          hash = "sha256-McSS9AOVfpcdX4d0KALdBTLpbMuzM5CObeAY7RadF7c=";
        };
      };
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (feishu) pname;
  __structuredAttrs = true;
  strictDeps = true;

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
