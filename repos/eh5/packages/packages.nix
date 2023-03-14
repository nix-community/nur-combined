{ pkgs, inputs ? null, filterByPlatform ? false }:
let
  inherit (pkgs) lib system;
  utils = import ../utils;
  callPackage = pkgs.newScope (self // {
    sources = callPackage ./_sources/generated.nix { };
  });
  self = self_base // (lib.optionalAttrs (inputs != null) self_extra);

  self_base = {
    dovecot-fts-flatcurve = callPackage ./dovecot-fts-flatcurve { };
    fake-hwclock = callPackage ./fake-hwclock { };
    hev-socks5-tproxy = callPackage ./hev-socks5-tproxy { };
    libnftnl-fullcone = callPackage ./libnftnl-fullcone { };
    mosdns = callPackage ./mosdns { buildGoModule = pkgs.buildGo119Module; };
    netease-cloud-music = callPackage ./netease-cloud-music { };
    nft-fullcone = callPackage ./nft-fullcone { };
    nftables-fullcone = callPackage ./nftables-fullcone { };
    nix-gfx-mesa = callPackage ./nix-gfx-mesa { };
    qcef = callPackage ./qcef { };
    stalwart-cli = callPackage ./stalwart-cli { };
    stalwart-imap = callPackage ./stalwart-imap { };
    stalwart-jmap = callPackage ./stalwart-jmap { };
    ubootNanopiR2s = callPackage ./uboot-nanopi-r2s { };
    v2ray-next = callPackage ./v2ray-next { buildGoModule = pkgs.buildGo120Module; };
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
