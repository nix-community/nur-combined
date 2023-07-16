{global, lib, ...}:
let
  inherit (global) username;
in {
  users.users.${username}.extraGroups = [ "vboxusers" ];

  virtualisation.virtualbox.host.enable = lib.mkDefault true;
}
