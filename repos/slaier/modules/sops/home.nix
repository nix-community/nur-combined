{ nixosConfig, ... }:
{
  sops = {
    defaultSopsFile = nixosConfig.sops.defaultSopsFile;
    age.keyFile = nixosConfig.sops.age.keyFile;
  };
}
