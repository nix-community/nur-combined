{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.printing;
in
{
  options.my.profiles.printing = with lib; {
    enable = mkEnableOption "printing profile";

    papersize = mkOption {
      type = with types; either str (enum [
        "a3"
        "a4"
        "a5"
        "b5"
        "letter"
        "legal"
        "executive"
        "note"
        "11x17"
      ]);
      default = "a4";
      example = "paper";
      description = "preferred paper size";
    };

    usb = {
      enable = my.mkDisableOption "USB printers";
    };

    network = {
      enable = my.mkDisableOption "network printers";
    };
  };

  config = lib.mkIf cfg.enable {
    # Setup CUPS
    services.printing = {
      enable = true;

      # Drivers are deprecated, but just in case
      drivers = with pkgs; [
        gutenprint # Base set of drivers
        brlaser # Brother drivers

        # Brother MFC-L3770CDW
        mfcl3770cdwlpr
        mfcl3770cdwcupswrapper
      ];
    };

    # Setup paper size
    systemd.services.cups.serviceConfig.Environment = [
      "PAPERSIZE=${cfg.papersize}"
    ];

    # Allow using USB printers
    services.ipp-usb = lib.mkIf cfg.usb.enable {
      enable = true;
    };

    # Allow using WiFi printers
    services.avahi = lib.mkIf cfg.network.enable {
      enable = true;
      openFirewall = true;
      # Allow resolution of '.local' addresses
      nssmdns = true;
    };
  };
}
