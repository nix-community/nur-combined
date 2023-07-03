{ ... }:

{
  security = {
    doas.extraConfig = ''
permit nopass :rfkillers as root cmd /run/current-system/sw/bin/rfkill
    '';
    sudo.extraConfig = ''
%rfkillers ALL=(root) NOPASSWD: /run/current-system/sw/bin/rfkill
    '';
  };
  users.extraGroups.rfkillers.members = [ "bjorn" ];
}
