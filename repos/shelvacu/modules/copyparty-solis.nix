{
  config,
  lib,
  vacuModules,
  vacuRoot,
  ...
}:
{
  imports = [ vacuModules.copyparty ];
  
  vacu.copyparties.solis = {
    domain = "files.solis.shelvacu.com";
    globalConfig = ''
      name: solis
    '';

    configureKanidm = lib.mkDefault false;
    configureFileServer = lib.mkDefault false;

    volumes."/xstore/torrents" = {
      bind.readOnly = true;
      access = "r.: shelvacu";
    };
  };

  vacu.oauthProxy.instances.${config.vacu.copyparties.solis.oauthInstance} = {
    clientSecret.sops = {
      sopsFile = /${vacuRoot}/secrets/solis-oauth.yaml;
      key = "copyparty_oauth";
    };
    displayName = "copyparty@solis";
    kanidmMembers = [ "shelvacu" ];
  };
}
