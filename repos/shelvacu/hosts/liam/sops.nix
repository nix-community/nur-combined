{ config, vacuModules, ... }:
{
  imports = [ vacuModules.sops ];

  config.sops.secrets = {
    dovecot-passwd = {
      restartUnits = [ "dovecot2.service" ];
    };
    dkim_key = {
      name = "dkimkeys/2024-03-liam.private";
      restartUnits = [ "opendkim.service" ];
      owner = config.services.opendkim.user;
    };
    relay_creds = {
      restartUnits = [ "postfix.service" ];
      owner = config.services.postfix.user;
    };
  };
}
