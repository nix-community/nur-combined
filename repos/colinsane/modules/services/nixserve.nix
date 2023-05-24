# docs: https://nixos.wiki/wiki/Binary_Cache
# to copy something to this machine's nix cache, do:
#   nix copy --to ssh://nixcache.uninsane.org PACKAGE
{ config, lib, ... }:

with lib;
let
  cfg = config.sane.services.nixserve;
in
{
  options = {
    sane.services.nixserve.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.services.nixserve.secretKeyFile = mkOption {
      type = types.path;
      description = "path to file that contains the nix_serve_privkey secret (should not be in the store)";
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      inherit (cfg) secretKeyFile;
      openFirewall = true;  # not needed for servo; only desko
    };
  };
}
