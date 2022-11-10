{ config, pkgs, lib, ... }:
let
  cfg = config.mail;
  postfixCfg = config.services.postfix;
  rspamdCfg = config.services.rspamd;
  secrets = config.sops.secrets;
in
{
  services.rspamd = {
    enable = true;
    postfix.enable = true;
    locals = {
      "milter_headers.conf".text = ''
        extended_spam_headers = yes;
      '';
      "redis.conf".text = ''
        servers = "${config.services.redis.servers.rspamd.unixSocket}";
      '';
      "classifier-bayes.conf".text = ''
        backend = "redis";
        autolearn = true;
      '';
      "dkim_signing.conf".text = ''
        selector = "dkim";
        # sops-nix secrets dir
        path = "/run/secrets/$domain.$selector.key";
      '';
      "multimap.conf".text = ''
        type = "ip";
        map = "${secrets.trustedNetworks.path}";
        prefilter = true;
        action = "accept";
      '';
    };

    overrides = {
      "milter_headers.conf".text = ''
        extended_spam_headers = true;
      '';
    };

    workers.rspamd_proxy = { };
    workers.controller = {
      count = 1;
      bindSockets = [
        {
          socket = "/run/rspamd/worker-controller.sock";
          mode = "0666";
        }
      ];
      extraConfig = ''
        password = "$2$kgwwpqtmia3dmsyenxi3ee1i34kg1ohj$ko7nat4pwbhkmczo6qkchy98fjxpypnw841pkwsza1s3cqmfhhqy"
      '';
    };
  };

  services.redis.servers.rspamd = {
    enable = true;
    port = 0;
    unixSocket = "/run/redis-rspamd/redis.sock";
    user = rspamdCfg.user;
  };
  boot.kernel.sysctl."vm.overcommit_memory" = 1;

  systemd.services.rspamd = {
    requires = [ "redis-rspamd.service" ];
    after = [ "redis-rspamd.service" ];
  };
}
