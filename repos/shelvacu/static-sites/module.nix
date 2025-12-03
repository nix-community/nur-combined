{ ... }@args:
let
  configs = import ./configs.nix args;
in
{
  services.caddy.virtualHosts = builtins.mapAttrs (_: val: { extraConfig = val; }) configs;
}
