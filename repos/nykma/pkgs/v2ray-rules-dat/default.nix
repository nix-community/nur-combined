{ lib, fetchurl, stdenvNoCC,
  unzip }:
let
  version = "202408072210";
  rules-zip = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/rules.zip";
    hash = "sha256-zNJ3L2gt5tiMmG+mThZz+mN7z3XyFYxW240zS+FH+ls=";
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "v2ray-rules-dat";

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip ${rules-zip}
    '';
  installPhase = ''
    mkdir -p $out/share/v2ray-rules-dat
    cp -r *.txt $out/share/v2ray-rules-dat
    cp -r *.dat $out/share/v2ray-rules-dat
    chmod 444 $out/share/v2ray-rules-dat/*
    '';

  meta = {
    description = "V2Ray 路由规则文件加强版，可代替 V2Ray 官方 geoip.dat 和 geosite.dat，兼容 Shadowsocks-windows、Xray-core、Trojan-Go、leaf 和 hysteria。Enhanced edition of V2Ray rules dat files, compatible with Xray-core, Shadowsocks-windows, Trojan-Go, leaf and hysteria.";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.licenses.gpl3;
  };
}
