{ callPackage }: {
  fake-hwclock = callPackage ./fake-hwclock { };
  mosdns = callPackage ./mosdns { };
  netease-cloud-music = callPackage ./netease-cloud-music { };
  qcef = callPackage ./qcef { };
  ubootNanopiR2s = callPackage ./uboot-nanopi-r2s { };
  v2ray-next = callPackage ./v2ray-next { };
  v2ray-rules-dat-geoip = callPackage ./v2ray-geoip { };
  v2ray-rules-dat-geosite = callPackage ./v2ray-geosite { };
}
