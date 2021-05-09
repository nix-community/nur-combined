{ ... }:
{
  my.profiles = {
    # Bluetooth configuration and GUI
    bluetooth.enable = true;
    # GTK theme configuration
    gtk.enable = true;
    # Laptop specific configuration
    laptop.enable = true;
    # i3 configuration
    wm.windowManager = "i3";
    # X configuration
    x.enable = true;
  };
}
