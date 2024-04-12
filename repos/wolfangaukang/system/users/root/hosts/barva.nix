{ inputs
, config
, ...
}:

{
  imports = [ "${inputs.self}/system/users/root" ];

  users.users.root.hashedPasswordFile = config.sops.secrets."user_pwd/root".path;
}
