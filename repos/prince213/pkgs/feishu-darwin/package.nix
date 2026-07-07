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
        version = "7.71.12";
        src = fetchurl {
          url = "${base}/ee-appcenter/0c65acbe/Feishu-darwin_arm64-7.71.12-signed.dmg";
          hash = "sha256-3xNJNn8T9Kuhn24DZorKt44f1eOwp13bvhOk4HWZ+nw=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.71.12";
        src = fetchurl {
          url = "${base}/ee-appcenter/474d1c55/Feishu-darwin_x64-7.71.12-signed.dmg";
          hash = "sha256-zZAe/sjP5/NQ/XEuQhH+LqPJm3HD4GinIFONbtohYp4=";
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
