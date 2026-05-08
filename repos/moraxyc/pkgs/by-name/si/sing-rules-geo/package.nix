{
  stdenvNoCC,
  metacubex-geo,
  v2ray-rules-dat,
  meta-rules-converter,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sing-rules-geo";
  inherit (v2ray-rules-dat) version src meta;

  outputs = [
    "out"
    "db"
    "geoip"
    "geosite"
  ];

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    metacubex-geo
    meta-rules-converter
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $db $geoip $geosite $out

    export HOME=$PWD
    geo convert ip -i v2ray -o sing -f $db/geoip.db geoip.dat
    geo convert site -i v2ray -o sing -f $db/geosite.db geosite.dat

    meta-rules-converter geoip -f geoip.dat -o $geoip -t sing-box
    meta-rules-converter geosite -f geosite.dat -o $geosite -t sing-box

    runHook postInstall
  '';
})
