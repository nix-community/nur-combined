{ config, lib, pkgs, ... }:

let
  inherit (builtins) toString;
  inherit (lib) mapAttrs mkOption types;

  hash-path-with-salt = pkgs.static-nix-shell.mkBash {
    pname = "hash-path-with-salt";
    src = ./.;
  };
  
  cfg = config.sane.derived-secrets;
  secret = types.submodule {
    options = {
      len = mkOption {
        type = types.int;
      };
      encoding = mkOption {
        type = types.enum [ "base64" ];
      };
    };
  };
in
{
  options = {
    sane.derived-secrets = mkOption {
      type = types.attrsOf secret;
      default = {};
      description = ''
        fs path => secret options.
        for each entry, we create an item at the given path whose value is deterministic,
        but also pseudo-random and not predictable by anyone without root access to the machine.
        as PRNG source we use the host ssh key, and derived secrets are salted based on the destination path.
      '';
    };
  };

  config = {
    sane.fs = mapAttrs (path: c: {
      generated.command = [
        "${hash-path-with-salt}/bin/hash-path-with-salt"
        path
        c.encoding
      ];
      generated.acl.mode = "0600";
    }) cfg;
  };
}
