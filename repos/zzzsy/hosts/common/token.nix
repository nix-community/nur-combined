{ config, ... }:
{
  vaultix.secrets.token = { };
  nix.extraOptions = ''
    !include ${config.vaultix.secrets.token.path}
  '';
}
