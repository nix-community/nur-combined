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
        version = "7.68.6";
        src = fetchurl {
          url = "${base}/ee-appcenter/0c7ea57c/Feishu-darwin_arm64-7.68.6-signed.dmg";
          hash = "sha256-G4jhCJFLd/hfnpRTTkdAsqqW+WyajQZXLYcJ/vbkM9M=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.68.6";
        src = fetchurl {
          url = "${base}/ee-appcenter/46d8fcfc/Feishu-darwin_x64-7.68.6-signed.dmg";
          hash = "sha256-x2zWdv9nWGeCRjXfVEl2sxpD0xJ6kKBg7ab87TbQ8lI=";
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
