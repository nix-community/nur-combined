# Shared by vavm (caddy, oauth2-proxy) and prophecy (kanidm).
{ lib, vacuRoot, ... }:
{
  imports = [ ./auto-oauth-proxy.nix ];
  vacu.oauthProxy.instances.tpictures = {
    appDomain = "tpictures.shelvacu.com";
    clientSecret.sops = {
      sopsFile = /${vacuRoot}/secrets/tpictures-oauth.yaml;
      key = "tpictures_oauth";
    };
    displayName = "tpictures";
    kanidmMembers = [ "shelvacu" ];

    configureCaddy = lib.mkDefault false;
    configureKanidm = lib.mkDefault false;
  };
}
