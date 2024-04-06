{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "v2ray-rules-dat";
  version = "202402242208";

  srcs = [
    (fetchurl {
      url = "https://github.com/Loyalsoldier/${finalAttrs.pname}/releases/download/${finalAttrs.version}/geoip.dat";
      hash = "sha256-NxnsYH80dPAq6Cd0z0G5dBmdyOH1/rOEe4Mjxu9vlQc=";
    })
    (fetchurl {
      url = "https://github.com/Loyalsoldier/${finalAttrs.pname}/releases/download/${finalAttrs.version}/geosite.dat";
      hash = "sha256-edPBydJ7pbf9hG92q5GewFxHgjI8qEBQh3N2GQ9JH30=";
    })
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

  meta = with lib; {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.getLicenseFromSpdxId "GPL-3.0-only";
    platforms = platforms.all;
  };
})
