{ config, lib, vaculib, ... }:
let
  socketDir = "/run/matrix-unix-socket";
  socketPath = "${socketDir}/socket.unix";
  delegatedName = "matrix.shelvacu.com";
  wellKnownServer = builtins.toJSON {
    "m.server" = delegatedName;
  };
  wellKnownClient = builtins.toJSON {
    "m.homeserver".base_url = "https://${delegatedName}";
  };
in
{
  systemd.tmpfiles.settings.whatever.${socketDir}.d = {
    user = config.services.matrix-continuwuity.user;
    group = "caddy";
    mode = vaculib.accessModeStr {
      user = "all";
      group = {
        read = true;
        execute = true;
      };
    };
  };

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      unix_socket_path = socketPath;
      unix_socket_perms = 666; # this is so cursed
      # unix_socket_perms = vaculib.accessModeStr { all.read = true; all.write = true; };
      server_name = "sv.mt";
      allow_federation = true;
      allow_announcements_check = false;
      new_user_displayname-suffix = "";
      ip_lookup_strategy = 1;
      log_colors = false;
    };
  };

  services.caddy.virtualHosts = {
    "matrix.shelvacu.com" = {
      vacu.hsts = "preload";
      extraConfig = ''
        reverse_proxy unix/${socketPath}
      '';
    };
    "sv.mt".extraConfig = lib.mkBefore ''
      handle /.well-known/matrix/server {
        header Content-Type application/json
        respond `${wellKnownServer}` 200
      }
      handle /.well-known/matrix/client {
        header Content-Type application/json
        respond `${wellKnownClient}` 200
      }
    '';
  };
}
