{ config, lib, ... }:

let
  inherit (builtins) toString;
  inherit (lib) mapAttrs mkOption types;
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
      generated.script.script = ''
        echo "$1" | cat /dev/stdin /etc/ssh/host_keys/ssh_host_ed25519_key \
          | sha512sum \
          | cut -c 1-${toString (c.len * 2)} \
          | tr a-z A-Z \
          | basenc -d --base16 \
          | basenc --${c.encoding} \
          > "$1"
      '';
      generated.script.scriptArgs = [ path ];
      generated.acl.mode = "0600";
    }) cfg;
  };
}
