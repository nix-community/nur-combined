{ pkgs, ... }:

let
  identity = import ../resources/identity.nix;
in
{
  allowedUnfree = [ "brgenml1lpr" ];

  services.printing = { enable = true; drivers = with pkgs; [ brgenml1cupswrapper ]; };

  hardware.printers = {
    ensureDefaultPrinter = "DCP-7065DN";
    ensurePrinters = [{
      name = "DCP-7065DN";
      description = "Brother DCP-7065DN";
      model = "brother-BrGenML1-cups-en.ppd";
      deviceUri = "lpd://lumberjack.home.arpa/binary_p1";
    }];
  };

  # Permissions
  users.users.${identity.username}.extraGroups = [ "lp" ];
}
