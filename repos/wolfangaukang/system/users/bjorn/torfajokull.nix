{ config, ... }:

{
  imports = [
    ./common.nix
    ./sops.nix
  ];

  users.users.bjorn.passwordFile = config.sops.secrets."user_pwd/bjorn".path;
}
