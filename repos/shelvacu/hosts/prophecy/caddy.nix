{
  config,
  lib,
  vacuModules,
  vaculib,
  vacuRoot,
  ...
}:
let
  cfg = config.services.caddy;
  caddyDir = directory: {
    inherit directory;
    inherit (cfg) user group;
    mode = vaculib.accessModeStr { user = "all"; };
  };
  socketDir = "/var/lib/caddy/admin-socket";
  socketPath = "${socketDir}/socket.unix";
in
{
  imports = [
    vacuModules.caddy-hsts
    /${vacuRoot}/static-sites/module.nix
  ];
  systemd.tmpfiles.settings."10-whatever".${socketDir}.d = {
    user = "caddy";
    group = "caddy";
    mode = vaculib.accessModeStr { user = "all"; };
  };
  environment.persistence."/persistent".directories = [
    (caddyDir cfg.logDir)
    (caddyDir cfg.dataDir)
  ];
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };
  services.caddy = {
    enable = true;
    # I was having weird issues where anytime I reloaded caddy, any browser that previously had pages open would spin endlessly trying to load any new ones (from this server) until caddy was restarted
    enableReload = false;
    email = "acme-certs@shelvacu.com";
    globalConfig = ''
      admin unix/${socketPath}
      skip_install_trust
    '';
    virtualHosts = {
      "sv.mt" = {
        vacu.hsts = "preload";
        extraConfig = ''redir / "https://www.youtube.com/watch?v=dQw4w9WgXcQ" temporary'';
      };
      "74358228.xyz" = {
        vacu.hsts = false;
        extraConfig = ''respond / "74358228 is awesome"'';
      };
      "shelvacu.com".vacu.hsts = "preload";
      "jobs.shelvacu.com".vacu.hsts = "preload";
      "jean-luc.org" = {
        vacu.hsts = "preload";
        extraConfig = ''respond / "Jean-luc is awesome"'';
      };
      "gabriel-dropout.for.miras.pet" = {
        vacu.hsts = false;
        extraConfig = ''
          root /propdata/trip/static-stuff/gabriel-dropout.for.miras.pet
          file_server browse
        '';
      };
      "shelvacu.miras.pet" = {
        vacu.hsts = false;
        extraConfig = ''respond / "I still don't know what to put here"'';
      };
      "habitat.pwrhs.win" = {
        vacu.hsts = false;
        extraConfig = ''
          reverse_proxy http://10.78.79.114:8123
        '';
      };
      "for.miras.pet" = {
        vacu.hsts = false;
        serverAliases = [
          "auth.for.miras.pet"
          "git.for.miras.pet"
          "wisdom.for.miras.pet"
          "chat.for.miras.pet"
        ];
        extraConfig = ''
          respond * "The *.for.miras.pet services have been taken down" 410
        '';
      };
    }
    // (lib.pipe
      [ "74358228.xyz" "jean-luc.org" "shelvacu.com" "sv.mt" ]
      [
        (map (
          domain:
          lib.nameValuePair "www.${domain}" {
            vacu.hsts = false;
            extraConfig = "redir https://${domain}{uri} permanent";
          }
        ))
        builtins.listToAttrs
      ]
    )
    // (lib.pipe
      [ "shelvacu.org" "www.shelvacu.org" "shelvacu.net" "www.shelvacu.net" ]
      [
        (map (
          domain:
          lib.nameValuePair domain {
            vacu.hsts = false;
            extraConfig = "redir https://shelvacu.com/{url}";
          }
        ))
        builtins.listToAttrs
      ]
    );
  };
  systemd.services.caddy.serviceConfig = {
    StateDirectoryMode = vaculib.accessModeStr { user = "all"; };
    SocketBindAllow = [
      "tcp:80"
      "tcp:443"
      "udp:443"
    ];
    SocketBindDeny = "any";
  };
}
