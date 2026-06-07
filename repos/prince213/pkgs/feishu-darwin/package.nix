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
        version = "7.69.9";
        src = fetchurl {
          url = "${base}/ee-appcenter/b258db78/Feishu-darwin_arm64-7.69.9-signed.dmg";
          hash = "sha256-tlj0Ap48zNiS2geHBslH9nGk4B2DpUUKbJqLx1oD8aU=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.69.9";
        src = fetchurl {
          url = "${base}/ee-appcenter/00082a1c/Feishu-darwin_x64-7.69.9-signed.dmg";
          hash = "sha256-733jDbLVNFNoPEo1V08gFn7nN1B/0YO4IuqfWGNvgYs=";
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
