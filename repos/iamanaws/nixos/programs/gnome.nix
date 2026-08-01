{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
    desktopManager.gnome.enable = true;
    displayManager.defaultSession = "gnome";
    displayManager.gdm.enable = true;

    udev = lib.mkIf config.hardware.nvidia.prime.offload.enable {
      packages =
        let
          pciPath =
            xorgBusId:
            let
              components = lib.drop 1 (lib.splitString ":" xorgBusId);
              toHex = i: lib.toLower (lib.toHexString (lib.toInt i));

              domain = "0000"; # Apparently the domain is practically always set to 0000
              bus = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 0));
              device = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 1));
              function = builtins.elemAt components 2; # The function is supposedly a decimal number
            in
            "dri/by-path/pci-${domain}:${bus}:${device}.${function}-card";
        in
        [
          (pkgs.writeTextDir "lib/udev/rules.d/62-gnome-gpu-priority.rules" ''
            SYMLINK=="dri/igpu1", TAG+="mutter-device-preferred-primary"
          '')

          (pkgs.writeTextDir "lib/udev/rules.d/61-gpu-offload.rules" ''
            SYMLINK=="${pciPath config.hardware.nvidia.prime.intelBusId}", SYMLINK+="dri/igpu1"
            SYMLINK=="${pciPath config.hardware.nvidia.prime.nvidiaBusId}", SYMLINK+="dri/dgpu1"
          '')
        ];
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-connections

    epiphany
    geary
    gnome-contacts
    gnome-console
    gnome-music
    gnome-tour
    gnome-system-monitor
    orca
    seahorse
    totem
    yelp
  ];
}
