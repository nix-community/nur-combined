{
  nixosModules,
  ...
}:
{
  imports = [
    nixosModules.profiles.core
    nixosModules.services.openssh
  ];

  networking.firewall.enable = true;
}
