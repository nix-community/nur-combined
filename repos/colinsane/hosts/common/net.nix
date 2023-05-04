{ config, lib, pkgs, ... }:

{
  # the default backend is "wpa_supplicant".
  # wpa_supplicant reliably picks weak APs to connect to.
  # see: <https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/474>
  # iwd is an alternative that shouldn't have this problem
  # docs:
  # - <https://nixos.wiki/wiki/Iwd>
  # - <https://iwd.wiki.kernel.org/networkmanager>
  # - `man iwd.config`  for global config
  # - `man iwd.network` for per-SSID config
  # use `iwctl` to control
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    # auto-connect to a stronger network if signal drops below this value
    # bedroom -> bedroom connection is -35 to -40 dBm
    # bedroom -> living room connection is -60 dBm
    General.RoamThreshold = "-52";  # default -70
    General.RoamThreshold5G = "-52";  # default -76
  };
}
