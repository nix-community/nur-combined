{ lib, runCommand, sources }:
let
  inherit (sources.geosite-dat) version src;
in
runCommand "v2ray-rules-dat-geosite-${version}"
{
  inherit version;
  meta = {
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    description = "Enhanced edition of V2Ray rules dat files, compatible with Xray-core, Shadowsocks-windows, Trojan-Go and leaf.";
    license = lib.licenses.gpl3;
  };
} ''
  install -TDm644 ${src} $out/share/v2ray/geosite.dat
''
