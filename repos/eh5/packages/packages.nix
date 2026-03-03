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
    dae-unstable = callPackage ./dae-unstable { };
    einat = callPackage ./einat { };
    fake-hwclock = callPackage ./fake-hwclock { };
    kcptun = callPackage ./kcptun { };
    mosdns = callPackage ./mosdns { };
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
