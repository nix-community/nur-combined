{ config, pkgs, lib, ... }:
let
  secrets = config.sops.secrets;
  certName = "eh5.me";
  acmeCert = config.security.acme.certs.${certName};
  caddyCfg = config.services.caddy;
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "i+acme@eh5.me";
      keyType = "ec256";
      dnsProvider = "cloudflare";
      credentialsFile = secrets.acmeEnv.path;
    };
    certs."eh5.me" = {
      extraDomainNames = [
        "sokka.cn"
        "*.eh5.me"
        "*.sokka.cn"
      ];
      postRun = ''
        export PATH="$PATH:${pkgs.sshpass}/bin"
        bash ${secrets.postScript.path} || true
      '';
      reloadServices = [
        "v2ray-next.service"
      ];
    };
  };
  security.dhparams.enable = true;

  # V2Ray
  services.v2ray-next = {
    enable = true;
    useV5Format = true;
    configFile = config.sops.secrets.v2rayConfig.path;
  };
  systemd.services.v2ray-next.requires = [ "acme-finished-${certName}.target" ];

  # Caddy
  users.users.${caddyCfg.user}.extraGroups = [ acmeCert.group ];
  services.caddy = {
    enable = true;
    package = pkgs.caddy; # XXX: use custom build with plugins?
    acmeCA = null;
    globalConfig = ''
      auto_https disable_certs
      default_sni eh5.me
    '';
  };
  services.caddy.virtualHosts = {
    "mail.eh5.me" = {
      serverAliases = [ "mx.eh5.me" "mx2.eh5.me" ];
      useACMEHost = certName;
      extraConfig = ''
        redir /rspamd /rspamd/
        handle_path /rspamd/* {
          reverse_proxy unix//run/rspamd/worker-controller.sock
        }
      '';
    };
    "autoconfig.eh5.me" = {
      serverAliases = [ "autoconfig.sokka.cn" ];
      useACMEHost = certName;
      extraConfig = ''
        handle_path /mail/* {
          header Content-Type application/xml
          root * `${caddyCfg.dataDir}/autoconfig`
          templates {
            mime application/xml text/xml text/html text/plain
          }
          file_server
        }
      '';
    };
    "autodiscover.eh5.me" = {
      serverAliases = [ "autodiscover.sokka.cn" ];
      useACMEHost = certName;
      extraConfig = ''
        handle_path /autodiscover/* {
          header Content-Type application/xml
          root * `${caddyCfg.dataDir}/autodiscover`
          file_server
        }
      '';
    };
  };

  systemd.services.autoconfig-setup = {
    script = ''
      PERM="-o${caddyCfg.user} -g${caddyCfg.group}"
      install -d $PERM ${caddyCfg.dataDir}
      rm -rf ${caddyCfg.dataDir}/autoconfig ${caddyCfg.dataDir}/autodiscover
      install -d $PERM ${caddyCfg.dataDir} ${caddyCfg.dataDir}/autoconfig ${caddyCfg.dataDir}/autodiscover
      cp -rt ${caddyCfg.dataDir}/autoconfig ${./files/autoconfig}/.
      cp -rt ${caddyCfg.dataDir}/autodiscover ${./files/autodiscover}/.
      chown -R ${caddyCfg.user}:${caddyCfg.group} ${caddyCfg.dataDir}/autoconfig ${caddyCfg.dataDir}/autodiscover
    '';
    requiredBy = [ "caddy.service" ];
    before = [ "caddy.service" ];
    serviceConfig.Type = "oneshot";
  };
}
