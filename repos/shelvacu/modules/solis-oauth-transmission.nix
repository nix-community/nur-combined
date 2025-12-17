{ config, lib, vacuModules, vacuRoot, ... }:
{
  imports = [ vacuModules.auto-oauth-proxy ];
  vacu.oauthProxy.instances.solis-transmission = {
    enable = true;
    appDomain = "xs.shelvacu.com";
    clientSecret.sops = {
      sopsFile = /${vacuRoot}/secrets/solis-oauth.yaml;
      key = "transmission_oauth";
    };
    displayName = "transmission@solis";
    kanidmMembers = [ "shelvacu" ];
    basicAuthAccounts.user = [
      # tremotesf on fw
      "$2a$14$OqmipjlCwoxETpd0AYK9LOM15z9/2CQGhCw2TVz169cECzBDT2XGe"
      # tremotesf on pixel9pro
      "$2a$14$iFmwwCNtFi33qWP2sYp/I.xlfatclr5HUeJ7Zioq6QMddXfBp.pC6"
    ];

    configureCaddy = lib.mkDefault false;
    configureKanidm = lib.mkDefault false;
  };

  services.caddy.virtualHosts = lib.mkIf config.vacu.oauthProxy.instances.solis-transmission.configureCaddy {
    ${config.vacu.oauthProxy.instances.solis-transmission.appDomain}.vacu.hsts = "preload";
  };
}
