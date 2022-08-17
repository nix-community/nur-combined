{ pkgs, filterByPlatform ? false }:
let
  utils = import ../utils;
  callPackage = pkgs.newScope (self // {
    sources = callPackage ./_sources/generated.nix { };
  });
  self = {
    fake-hwclock = callPackage ./fake-hwclock { };
    mosdns = callPackage ./mosdns { buildGoModule = pkgs.buildGo119Module; };
    netease-cloud-music = callPackage ./netease-cloud-music { };
    nix-gfx-mesa = callPackage ./nix-gfx-mesa { };
    qcef = callPackage ./qcef { };
    ubootNanopiR2s = callPackage ./uboot-nanopi-r2s { };
    v2ray-next = callPackage ./v2ray-next { buildGoModule = pkgs.buildGo118Module; };
    v2ray-rules-dat-geoip = callPackage ./v2ray-geoip { };
    v2ray-rules-dat-geosite = callPackage ./v2ray-geosite { };
  };
in
if filterByPlatform
then pkgs.lib.filterAttrs (n: v: utils.checkPlatform pkgs.system v) self
else self
