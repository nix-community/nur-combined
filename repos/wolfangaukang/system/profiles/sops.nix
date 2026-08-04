# Sops setup for any host
{
  inputs,
  ...
}:

let
  inherit (inputs) self sops;

in
{
  imports = [
    sops.nixosModules.sops
  ];

  sops.defaultSopsFile = "${self}/system/hosts/common/secrets.yml";
}
