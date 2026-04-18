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
        version = "7.66.5";
        src = fetchurl {
          url = "${base}/ee-appcenter/1ec6582e/Feishu-darwin_arm64-7.66.5-signed.dmg";
          hash = "sha256-jrH/BitotgRbnSMci0ugDr2kxR9IqTeSuf8CUj2LPZY=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.66.5";
        src = fetchurl {
          url = "${base}/ee-appcenter/1b5e2d12/Feishu-darwin_x64-7.66.5-signed.dmg";
          hash = "sha256-CWaOjdrB2yRYV9rw1RPDIA4pUcgDmg1umHFRczsviCI=";
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
