{
  config,
  lib,
  pkgs,
  ...
}:
{
  disabledModules = [ "security/pam.nix" ];

  imports = [
    ./security/pam.nix
  ];
}
