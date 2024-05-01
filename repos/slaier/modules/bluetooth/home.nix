{
  services.mpris-proxy.enable = true;
  xdg.configFile."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
    bluez_monitor.properties = {
      ["bluez5.enable-hw-volume"] = false,
    }
  '';
}
