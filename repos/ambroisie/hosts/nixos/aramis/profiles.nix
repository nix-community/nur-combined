{ ... }:
{
  my.profiles = {
    # Bluetooth configuration and GUI
    bluetooth.enable = true;
    # Mouse and keyboard configuration
    devices.enable = true;
    # GTK theme configuration
    gtk.enable = true;
    # Laptop specific configuration
    laptop.enable = true;
    # Printers are hell, but so is the unability to print
    printing.enable = true;
    # i3 configuration
    wm.windowManager = "i3";
    # X configuration
    x.enable = true;
  };
}
