{config, pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix
  ] ++ builtins.attrValues (import ./modules);
}
