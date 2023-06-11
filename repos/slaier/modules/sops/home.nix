{ config, nixosConfig, ... }:
{
  sops = {
    defaultSopsFile = nixosConfig.sops.defaultSopsFile;
    age.keyFile = nixosConfig.sops.age.keyFile;
  };
  home.sessionVariables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
}
