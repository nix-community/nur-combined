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
    sane.services.nixserve.port = mkOption {
      default = 5001;
      type = types.port;
    };
    sane.services.nixserve.secretKeyFile = mkOption {
      type = types.path;
      description = "path to file that contains the nix_serve_privkey secret (should not be in the store)";
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      inherit (cfg) port secretKeyFile;
    };
    sane.ports.ports."${builtins.toString cfg.port}" = {
      visibleTo.lan = true;  # not needed for servo; only desko
      protocol = [ "tcp" ];
      description = "colin-nix-serve-cache";
    };
  };
}
