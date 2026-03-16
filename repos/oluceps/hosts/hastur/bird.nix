{ config, ... }:
{
  repack.bird = {
    enable = true;
    config = ''
      include "${config.vaultix.secrets.babel-auth.path}";
    '';
  };
}
