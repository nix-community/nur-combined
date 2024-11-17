{ lib, ... }:

let
  host = lib.types.submodule ({ config, name, ... }: {
    options = with lib; {
      names = mkOption {
        type = types.listOf types.str;
        description = ''
          all names by which this host is reachable
        '';
      };
      ssh.user_pubkey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          ssh pubkey that the primary user of this machine will use when connecting to other machines.
          e.g. "ssh-ed25519 AAAA<base64>".
        '';
      };
      ssh.host_pubkey = mkOption {
        type = types.str;
        description = ''
          ssh pubkey which this host will present to connections initiated against it.
          e.g. "ssh-ed25519 AAAA<base64>".
        '';
      };
      ssh.authorized = mkOption {
        type = types.bool;
        default = true;
        description = "make this host's ssh key be an authorized_key for the system being deployed to";
      };
      wg-home.pubkey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          wireguard public key for the wg-home VPN.
          e.g. "pWtnKW7f7sNIZQ2M83uJ7cHg3IL1tebE3IoVkCgjkXM=".
        '';
      };
      wg-home.ip = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          IP address to use on the wg-home VPN.
          e.g. "10.0.10.5";
        '';
      };
      wg-home.endpoint = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      lan-ip = mkOption {
        type = types.str;
        description = ''
          ip address when on the lan.
          e.g. "192.168.0.5";
        '';
      };
    };

    config = {
      names = [ name ]
        ++ lib.optional (config.wg-home.ip != null) "${name}-hn";
    };
  });
in
{
  options = {
    sane.hosts.by-name = with lib; mkOption {
      type = types.attrsOf host;
      default = {};
      description = ''
        map of hostname => attrset of information specific to that host,
        like its ssh pubkey, etc.
      '';
    };
  };
}
