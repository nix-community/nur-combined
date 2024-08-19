{ config, ... }:
{
  sops.secrets.access-tokens = {
    mode = "0440";
    sopsFile = ../../secrets/tokens;
    format = "binary";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets.access-tokens.path}
  '';
}
