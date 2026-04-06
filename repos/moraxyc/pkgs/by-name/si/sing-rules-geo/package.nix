{
  stdenvNoCC,
  metacubex-geo,
  v2ray-rules-dat,
  meta-rules-converter,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sing-rules-geo";
  inherit (v2ray-rules-dat) version srcs meta;

  outputs = [
    "out"
    "db"
    "geoip"
    "geosite"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  nativeBuildInputs = [
    metacubex-geo
    meta-rules-converter
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $db $geoip $geosite $out
    export HOME=$PWD
    geo convert ip -i v2ray -o sing -f geoip.db ${builtins.elemAt finalAttrs.srcs 0}
    geo convert site -i v2ray -o sing -f geosite.db ${builtins.elemAt finalAttrs.srcs 1}
    cp -r geo{ip,site}.db $db

    meta-rules-converter geoip -f ${builtins.elemAt finalAttrs.srcs 0} -o $geoip -t sing-box
    meta-rules-converter geosite -f ${builtins.elemAt finalAttrs.srcs 1} -o $geosite -t sing-box

    runHook postInstall
  '';
})
