{ pkgs, inputs ? null, filterByPlatform ? false }:
let
  inherit (pkgs) lib system;
  utils = import ../utils;
  callPackage = pkgs.newScope (self // {
    sources = callPackage ./_sources/generated.nix { };
  });
  self = self_base // (lib.optionalAttrs (inputs != null) self_extra);

  self_base = {
    fake-hwclock = callPackage ./fake-hwclock { };
    mosdns = callPackage ./mosdns { buildGoModule = pkgs.buildGo119Module; };
    netease-cloud-music = callPackage ./netease-cloud-music { };
    nix-gfx-mesa = callPackage ./nix-gfx-mesa { };
    qcef = callPackage ./qcef { };
    ubootNanopiR2s = callPackage ./uboot-nanopi-r2s { };
    v2ray-next = callPackage ./v2ray-next { buildGoModule = pkgs.buildGo119Module; };
    v2ray-rules-dat-geoip = callPackage ./v2ray-geoip { };
    v2ray-rules-dat-geosite = callPackage ./v2ray-geosite { };
    vlmcsd = callPackage ./vlmcsd { };
  };
  self_extra = lib.optionalAttrs
    (lib.hasAttrByPath [ system "sops-install-secrets" ] inputs.sops-nix.packages)
    {
      sops-install-secrets-nonblock = callPackage ./sops-install-secrets-nonblock {
        inherit (inputs.sops-nix.packages.${system}) sops-install-secrets;
      };
    }
  ;
in
if filterByPlatform
then pkgs.lib.filterAttrs (n: v: utils.checkPlatform pkgs.system v) self
else self
