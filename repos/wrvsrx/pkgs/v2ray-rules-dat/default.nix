{
  fetchurl,
  stdenvNoCC,
}:
let
  version = "202604272244";
  geoip = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/geoip.dat";
    hash = "sha256-tBIMiH8sgS5fV1Ucg0F+xvZo7haZnLLGICIdDAY8zfQ=";
  };
  geosite = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/geosite.dat";
    hash = "sha256-rOi6gre4uYFiW0ng2ePVjGfaPINCS/lY0WWuwH5bNcw=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "v2ray-rules-dat";
  inherit version;
  unpackPhase = "true";
  installPhase = ''
    install -D -m 644 ${geoip} $out/share/v2ray-rules-dat/geoip.dat
    install -D -m 644 ${geosite} $out/share/v2ray-rules-dat/geosite.dat
  '';
}
