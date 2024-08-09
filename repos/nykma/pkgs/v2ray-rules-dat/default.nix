{ lib, fetchurl, stdenvNoCC,
  unzip }:
let
  version = "202408082210";
  rules-zip = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/rules.zip";
    hash = "sha256-zNJ3L2gt5tiMmG+mThZz+mN7z3XyFYxW240zS+FH+ls=";
  };
  china-list = fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${version}/china-list.txt";
    hash = "sha256-W0vtJPe6am/V27wJkZLbUs/gTyAV2o3997dnggoe6BA=";
  };
in
# .
# └── share
#     └── v2ray-rules-dat
#         ├── china-list.txt
#         ├── direct-list.txt
#         ├── geoip.dat
#         ├── geosite.dat
#         ├── proxy-list.txt
#         └── reject-list.txt
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
    cp ${china-list} $out/share/v2ray-rules-dat/china-list.txt
    chmod 444 $out/share/v2ray-rules-dat/*
    '';

  meta = {
    description = "V2Ray 路由规则文件加强版，可代替 V2Ray 官方 geoip.dat 和 geosite.dat，兼容 Shadowsocks-windows、Xray-core、Trojan-Go、leaf 和 hysteria。Enhanced edition of V2Ray rules dat files, compatible with Xray-core, Shadowsocks-windows, Trojan-Go, leaf and hysteria.";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = lib.licenses.gpl3;
  };
}
