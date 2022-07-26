{global, ...}:
let
  inherit (global) username;
in {
  users.users.${username}.extraGroups = [ "vboxusers" ];

  virtualisation.virtualbox.host.enable = true;
}
