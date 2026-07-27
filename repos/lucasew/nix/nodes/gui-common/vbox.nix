{
  global,
  lib,
  config,
  ...
}:
let
  inherit (global) username;
in
{

  config = lib.mkIf config.virtualisation.virtualbox.host.enable {
    users.users.${username}.extraGroups = [ "vboxusers" ];
  };

}
