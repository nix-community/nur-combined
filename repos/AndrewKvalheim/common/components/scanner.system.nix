let
  identity = import ../resources/identity.nix;
in
{
  allowedUnfree = [ "brother-udev-rule-type1" "brscan4" "brscan4-etc-files" ];

  hardware.sane = { enable = true; brscan4.enable = true; };

  hardware.sane.brscan4.netDevices = {
    DCP-7065DN = { model = "DCP-7065DN"; nodename = "lumberjack.home.arpa"; };
  };

  # Permissions
  users.users.${identity.username}.extraGroups = [ "scanner" ];
}
