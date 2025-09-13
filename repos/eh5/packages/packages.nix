{
  pkgs,
  inputs ? null,
  filterByPlatform ? false,
}:
let
  inherit (pkgs) lib system;
  utils = import ../utils;
  callPackage = pkgs.newScope (
    self
    // {
      sources = callPackage ./_sources/generated.nix { };
    }
  );
  self = self_base // (lib.optionalAttrs (inputs != null) self_extra);

  self_base = {
    einat = callPackage ./einat { };
    fake-hwclock = callPackage ./fake-hwclock { };
    kcptun = callPackage ./kcptun { };
    libnftnl-fullcone = callPackage ./libnftnl-fullcone { };
    mosdns = callPackage ./mosdns { };
    # end of service
    #netease-cloud-music = callPackage ./netease-cloud-music { };

    # out-of-tree module outdated, and failed to compile against kernel 6.12 structs
    #nft-fullcone = callPackage ./nft-fullcone { };
    #nftables-fullcone = callPackage ./nftables-fullcone { };
    nix-gfx-mesa = callPackage ./nix-gfx-mesa { };
    # built failure with gnome2.ORBit2
    # qcef = callPackage ./qcef { };
    rtl8152-led-ctrl = callPackage ./rtl8152-led-ctrl { };
    udpspeeder = callPackage ./udpspeeder { };
    ubootNanopiR2s = callPackage ./uboot-nanopi-r2s { };
    vlmcsd = callPackage ./vlmcsd { };
  };

  self_extra = sops-nix_pkgs;

  sops-nix_pkgs =
    lib.optionalAttrs
      (lib.hasAttrByPath [
        system
        "sops-install-secrets"
      ] inputs.sops-nix.packages)
      {
        sops-install-secrets-nonblock = callPackage ./sops-install-secrets-nonblock {
          inherit (inputs.sops-nix.packages.${system}) sops-install-secrets;
        };
      };
in
if filterByPlatform then
  pkgs.lib.filterAttrs (n: v: utils.checkPlatform pkgs.system v) self
else
  self
