{
  v2ray-rules-dat-geoip,
  v2ray-rules-dat-geosite,
  stdenvNoCC,
}:
assert (v2ray-rules-dat-geoip.version == v2ray-rules-dat-geosite.version);
stdenvNoCC.mkDerivation {
  pname = "v2ray-rules-dat";
  inherit (v2ray-rules-dat-geoip) version;
  unpackPhase = "true";
  installPhase = ''
    install -D -m 644 ${v2ray-rules-dat-geoip.src} $out/share/v2ray-rules-dat/geoip.dat
    install -D -m 644 ${v2ray-rules-dat-geosite.src} $out/share/v2ray-rules-dat/geosite.dat
  '';
}
