{
  lib,
  stdenvNoCC,
  sources,
  source ? sources.v2ray-rules-dat,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "v2ray-rules-dat";
  version = source.date;
  inherit (source) src;

  outputs = [
    "out"
    "lists"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    sha256sum -c geoip.dat.sha256sum
    sha256sum -c geosite.dat.sha256sum

    mkdir -p $out/share/v2ray $lists
    install -Dm644 geo{ip,site}.dat $out/share/v2ray

    cp -r *.txt $lists

    runHook postInstall
  '';

  meta = {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.licenses.gpl3Only;
  };
})
