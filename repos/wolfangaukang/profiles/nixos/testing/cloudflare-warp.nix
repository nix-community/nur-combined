{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cloudflare-warp"
  ];
  services.cloudflare-warp = {
    enable = true;
  };
}
