{ config, lib, ... }:

with lib;
let
  key = types.submodule ({ name, config, ...}: {
    options = {
      typedPubkey = mkOption {
        type = types.str;
        description = ''
          the pubkey with type attached.
          e.g. "ssh-ed25519 <base64>"
        '';
      };
      # type = mkOption {
      #   type = types.str;
      #   description = ''
      #     the type of the key, e.g. "id_ed25519"
      #   '';
      # };
      host = mkOption {
        type = types.str;
        description = ''
          the hostname of a key
        '';
      };
      user = mkOption {
        type = types.str;
        description = ''
          the username of a key
        '';
      };
      asUserKey = mkOption {
        type = types.str;
        description = ''
          append the "user@host" value to the pubkey to make it usable for ~/.ssh/id_<x>.pub or authorized_keys
        '';
      };
      asHostKey = mkOption {
        type = types.str;
        description = ''
          prepend the "host" value to the pubkey to make it usable for ~/.ssh/known_hosts
        '';
      };
    };
    config = rec {
      user = head (lib.splitString "@" name);
      host = last (lib.splitString "@" name);
      asUserKey = "${config.typedPubkey} ${name}";
      asHostKey = "${host} ${config.typedPubkey}";
    };
  });
  coercedToKey = types.coercedTo types.str (typedPubkey: {
    inherit typedPubkey;
  }) key;
in
{
  options = {
    sane.ssh.pubkeys = mkOption {
      type = types.attrsOf coercedToKey;
      default = {};
      description = ''
        mapping from "user@host" to pubkey.
      '';
    };
  };

  config = {
    # persist the host key.
    # actually DON'T do it this way. else we compete with the /etc activation script and it triggers warnings on deploys.
    # sane.persist.sys.byStore.plaintext = [ "/etc/ssh/host_keys" ];
    # N.B.: use the plaintext `backing` dir instead of proper persistence, because this needs to be available
    # during activation time (see /etc/machine-id and setupSecretsForUsers activation script).
    # TODO: this should go in the same dir as `/var/log`, then. i.e. `stores.initrd` (but rename to `stores.early`).
    environment.etc."ssh/host_keys" = let
      plaintextBacking = config.sane.fs."${config.sane.persist.stores.plaintext.origin}".mount.bind;
    in lib.mkIf config.sane.persist.enable {
      source = "${plaintextBacking}/etc/ssh/host_keys";
    };

    # let openssh find our host keys
    services.openssh.hostKeys = [
      { type = "rsa"; bits = 4096; path = "/etc/ssh/host_keys/ssh_host_rsa_key"; }
      { type = "ed25519"; path = "/etc/ssh/host_keys/ssh_host_ed25519_key"; }
    ];

    services.openssh.knownHosts =
    let
      host-keys = filter (k: k.user == "root") (attrValues config.sane.ssh.pubkeys);
    in lib.mkMerge (builtins.map (key: {
      "${key.host}".publicKey = key.typedPubkey;
    }) host-keys);
  };
}
