{
  config,
  pkgs,
  lib,
  vaculib,
  vacuModules,
  ...
}:
let
  domain = "id.shelvacu.com";
  webListenPort = 26181;
  webListenIP = "127.151.238.25";
  kaniCfg = config.services.kanidm;
  tls_dir = "/var/cache/kanidm/certs";
  cacheDirCommon = {
    CacheDirectory = "kanidm";
    CacheDirectoryMode = vaculib.accessModeStr { user = "all"; };
  };
in
{
  imports = [
    vacuModules.solis-oauth-transmission
    vacuModules.copyparty-solis
  ];
  vacu.oauthProxy.instances.solis-transmission.configureKanidm = true;
  vacu.copyparties.solis.configureKanidm = true;

  systemd.services.ensure-kanidm-certs =
    let
      template_file = pkgs.writeText "kanidm-selfsigned-certtool-template" ''
        cn = "kanidm self-signed cert"
        expiration_days = -1
        signing_key
        encryption_key
        tls_www_server
      '';
    in
    {
      path = [ pkgs.gnutls ];
      confinement.packages = [
        pkgs.gnutls
        template_file
        pkgs.coreutils
      ];
      confinement.enable = true;
      enableStrictShellChecks = true;
      requiredBy = [ "kanidm.service" ];
      before = [ "kanidm.service" ];
      serviceConfig = {
        User = "kanidm";
        Group = "kanidm";
        Type = "oneshot";
        RemainAfterExit = true;
      }
      // cacheDirCommon;
      script = ''
        set -euo pipefail

        declare tls_key=${lib.escapeShellArg kaniCfg.serverSettings.tls_key}
        declare tls_chain=${lib.escapeShellArg kaniCfg.serverSettings.tls_chain}
        if [[ -f $tls_chain ]]; then
          # files already created
          exit 0
        fi
        declare dir
        dir="$(dirname -- "$tls_key")"
        mkdir -p -- "$dir"
        certtool --generate-privkey --outfile="$tls_key" --key-type=rsa --sec-param=high
        certtool --generate-self-signed --load-privkey="$tls_key" --outfile="$tls_chain" --template=${template_file}
        chmod u=r,g=,o= -- "$tls_key"
        chmod u=r,g=r,o=r -- "$tls_chain"
      '';
    };

  services.kanidm = {
    enableServer = true;
    enableClient = true;
    package = pkgs.kanidmWithSecretProvisioning_1_8;
    serverSettings = {
      inherit domain;
      origin = "https://${domain}";
      bindaddress = "${webListenIP}:${builtins.toString webListenPort}";
      #no ldap, for now
      tls_chain = "${tls_dir}/tls_chain.pem";
      tls_key = "${tls_dir}/tls_key.pem";
      trust_x_forward_for = true;
      online_backup = {
        path = "/propdata/kanidm-backups";
        schedule = "46 03 * * *";
        versions = 20;
      };
    };
    provision = {
      instanceUrl = "https://${kaniCfg.serverSettings.bindaddress}";
      acceptInvalidCerts = true;
      groups."general_access".overwriteMembers = false;
      persons.shelvacu = {
        present = true;
        mailAddresses = [ "shelvacu@id.shelvacu.com" ];
        groups = [ "general_access" ];
        displayName = "Shelvacu";
      };
    };
    clientSettings = {
      uri = "https://${kaniCfg.serverSettings.bindaddress}";
      verify_ca = false;
      verify_hostnames = false;
    };
  };

  systemd.services.kanidm.serviceConfig = {
    AmbientCapabilities = lib.mkForce [ ];
    CapabilityBoundingSet = lib.mkForce [ ];
    SocketBindAllow = [ "tcp:${toString webListenPort}" ];
    SocketBindDeny = [ "any" ];
    TimeoutStartSec = 120;
  }
  // cacheDirCommon;

  services.caddy.virtualHosts.${domain} = {
    vacu.hsts = "preload";
    extraConfig = ''
      reverse_proxy * {
        to https://${webListenIP}:${builtins.toString webListenPort}
        transport http {
          tls_insecure_skip_verify
        }
      }
    '';
  };
}
