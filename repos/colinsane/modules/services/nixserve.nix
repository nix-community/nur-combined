# docs: <https://nixos.wiki/wiki/Binary_Cache>
# to copy something to this machine's nix cache, do:
#   nix copy --to ssh://nixcache.uninsane.org PACKAGE
#
# docs: <https://nixos.wiki/wiki/Distributed_build>
# to use this machine as a remote builder, just build anything with `-j0`.
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
    sane.services.nixserve.remoteBuilderPubkey = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # act as a substituter
    sane.ports.ports."${builtins.toString cfg.port}" = {
      visibleTo.lan = true;  # not needed for servo; only desko
      protocol = [ "tcp" ];
      description = "colin-nix-serve-cache";
    };
    services.nix-serve = {
      enable = true;
      inherit (cfg) port secretKeyFile;
    };

    # XXX(2024/01/19): upstream service specifies `User=nix-serve`, `Group=nix-serve` but doesn't define the users.
    # this causes a coredump loop from within a nix-serve subprocess.
    users.users.nix-serve = {
      group = "nix-serve";
      isSystemUser = true;
    };
    users.groups.nix-serve = {};

    # act as a remote builder
    nix.settings.trusted-users = [ "nixremote" ];
    users.users.nixremote = {
      isNormalUser = true;
      home = "/home/nixremote";
      # remove write permissions everywhere in the home dir.
      # combined with an ownership of root:nixremote, that means not even nixremote can write anything below this directory
      # (in which case, i'm not actually sure why nixremote needs a home)
      homeMode = "550";
      group = "nixremote";
      subUidRanges = [
        { startUid=300000; count=1; }
      ];
      initialPassword = "";
      openssh.authorizedKeys.keys = [
        cfg.remoteBuilderPubkey
      ];
    };

    users.groups.nixremote = {};

    sane.users.nixremote = {
      fs."/".dir.acl = {
        # don't allow the user to write anywhere
        user = "root";
        group = "nixremote";
      };
    };
  };
}
