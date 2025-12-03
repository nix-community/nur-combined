{
  inputs,
  config,
  ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    "${self}/system/users/root"
    "${self}/system/users/root/sops.nix"
  ];

  users.users.root.hashedPasswordFile = config.sops.secrets."user_pwd/root".path;
}
