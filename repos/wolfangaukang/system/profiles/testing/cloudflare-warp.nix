{
  lib,
  inputs,
  ...
}:

{

  imports = [ inputs.self.nixosModules.cloudflare-warp ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "cloudflare-warp"
    ];
  services.cloudflare-warp = {
    enable = true;
    logLevel = "INFO";
  };
}
