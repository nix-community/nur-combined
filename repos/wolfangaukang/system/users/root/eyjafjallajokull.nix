{ config, ... }:

{
  imports = [
    ./common.nix
    ./sops.nix
  ];

  users.users.root.passwordFile = config.sops.secrets."user_pwd/root".path;
}
