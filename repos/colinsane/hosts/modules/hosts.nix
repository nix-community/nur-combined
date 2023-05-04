{ config, lib, ... }:

let
  inherit (lib) attrValues filterAttrs mkMerge mkOption types;
  cfg = config.sane.hosts;

  host = types.submodule ({ config, ... }: {
    options = {
      ssh.user_pubkey = mkOption {
        type = types.str;
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
  });
in
{
  options = {
    sane.hosts.by-name = mkOption {
      type = types.attrsOf host;
      default = {};
      description = ''
        map of hostname => attrset of information specific to that host,
        like its ssh pubkey, etc.
      '';
    };
  };

  config = {
    # TODO: this should be populated per-host
    sane.hosts.by-name."desko" = {
      ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU5GlsSfbaarMvDA20bxpSZGWviEzXGD8gtrIowc1pX";
      ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw9NoRaYrM6LbDd3aFBc4yyBlxGQn8HjeHd/dZ3CfHk";
      wg-home.pubkey = "17PMZssYi0D4t2d0vbmhjBKe1sGsE8kT8/dod0Q2CXc=";
      wg-home.ip = "10.0.10.22";
      lan-ip = "192.168.15.25";
    };

    sane.hosts.by-name."lappy" = {
      ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpmFdNSVPRol5hkbbCivRhyeENzb9HVyf9KutGLP2Zu";
      ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSJnqmVl9/SYQ0btvGb0REwwWY8wkdkGXQZfn/1geEc";
      wg-home.pubkey = "FTUWGw2p4/cEcrrIE86PWVnqctbv8OYpw8Gt3+dC/lk=";
      wg-home.ip = "10.0.10.20";
      lan-ip = "192.168.15.8";
    };

    sane.hosts.by-name."moby" = {
      ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrR+gePnl0nV/vy7I5BzrGeyVL+9eOuXHU1yNE3uCwU";
      ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1N/IT3nQYUD+dBlU1sTEEVMxfOyMkrrDeyHcYgnJvw";
      wg-home.pubkey = "I7XIR1hm8bIzAtcAvbhWOwIAabGkuEvbWH/3kyIB1yA=";
      wg-home.ip = "10.0.10.48";
      lan-ip = "192.168.15.21";
    };

    sane.hosts.by-name."servo" = {
      ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPS1qFzKurAdB9blkWomq8gI1g0T3sTs9LsmFOj5VtqX";
      ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfdSmFkrVT6DhpgvFeQKm3Fh9VKZ9DbLYOPOJWYQ0E8";
      wg-home.pubkey = "roAw+IUFVtdpCcqa4khB385Qcv9l5JAB//730tyK4Wk=";
      wg-home.ip = "10.0.10.5";
      wg-home.endpoint = "uninsane.org:51820";
      lan-ip = "192.168.15.24";
    };
  };
}
