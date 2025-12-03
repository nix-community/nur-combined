{
  config,
  inputs,
  ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    "${self}/system/users/bjorn"
    "${self}/system/users/bjorn/sops.nix"
  ];

  users.users.bjorn = {
    extraGroups = [ "video" ];
    hashedPasswordFile = config.sops.secrets."user_pwd/bjorn".path;
  };

  virtualisation.docker.storageDriver = "btrfs";

}
