{
  config,
  lib,
  pkgs,
  vacuModules,
  vacuRoot,
  ...
}:
{
  imports = [ vacuModules.copyparty ];
  
  vacu.copyparties.solis = {
    domain = "files.solis.shelvacu.com";
    package = pkgs.copyparty.override {
      withHashedPasswords = true;
      withCertgen = false;
      withThumbnails = true;
      withFastThumbnails = false;
      withMediaProcessing = false;
      withBasicAudioMetadata = true;
      withZeroMQ = false;
      withFTP = true;
      withFTPS = true;
      withTFTP = false;
      withSMB = false;
      withMagic = true;
    };
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
