{ config, vacuModules, ... }:
{
  imports = [ vacuModules.sops ];

  config.sops = {
    secrets.dovecot-passwd = {
      restartUnits = [ "dovecot2.service" ];
    };
    secrets.dkim_key = {
      name = "dkimkeys/2024-03-liam.private";
      restartUnits = [ "opendkim.service" ];
      owner = config.services.opendkim.user;
    };
    secrets.relay_creds = {
      restartUnits = [ "postfix.service" ];
      owner = config.services.postfix.user;
    };
  };
}
