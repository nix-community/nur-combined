{
  lib,
  stdenvNoCC,
  fetchurl,
  sources,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "v2ray-rules-dat";
  inherit (sources.v2ray-rules-dat-geoip) version;

  srcs = [
    sources.v2ray-rules-dat-geoip.src
    sources.v2ray-rules-dat-geosite.src
  ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${builtins.elemAt finalAttrs.srcs 0} $out/share/v2ray/geoip.dat
    install -Dm644 ${builtins.elemAt finalAttrs.srcs 1} $out/share/v2ray/geosite.dat

    runHook postInstall
  '';

  meta = {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.licenses.gpl3Only;
  };
})
