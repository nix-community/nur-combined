{ config
, inputs
, ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    "${self}/system/users/bjorn"
  ];

  users.users.bjorn = {
    extraGroups = [ "video" ];
    hashedPasswordFile = config.sops.secrets."user_pwd/bjorn".path;
  };
}
