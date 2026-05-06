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
        version = "7.67.9";
        src = fetchurl {
          url = "${base}/ee-appcenter/0e2f90a9/Feishu-darwin_arm64-7.67.9-signed.dmg";
          hash = "sha256-laBmF2spP1+H8mY+hq9KxaYwFjq9F4uI2yXUZPj+/o4=";
        };
      };
      # curl 'https://www.feishu.cn/api/package_info?platform=6'
      x86_64-darwin = {
        version = "7.67.9";
        src = fetchurl {
          url = "${base}/ee-appcenter/a1b3924c/Feishu-darwin_x64-7.67.9-signed.dmg";
          hash = "sha256-7UyFZ2NH9nrIm+htV3db+MbKx8V+vgR798JKkBqE9l4=";
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
