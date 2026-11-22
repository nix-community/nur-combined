{
  pkgs,
  flakeRoot,
  nixosModules,
  ...
}:

let
  secrets = flakeRoot + /secrets;
in

{
  imports = [
    secrets
  ]
  ++ (with nixosModules; [
    hardened
    programs.lanzaboote
    services.automount
  ]);

  # To test on this machine (battery drain while suspended):
  # - Deep idle: low_power_idle_system_residency_us under
  #   /sys/devices/system/cpu/cpuidle should grow by about the time asleep.
  # - nix-mineral blocks the Intel ME driver, and a device without its driver
  #   stays powered: check /sys/bus/pci/devices/*/power_state, then retry with
  #   nix-mineral.kernel-modules.disable.intelme-related = false.
  # - A kernel warning during resume panics and reboots to the LUKS prompt,
  #   which never sleeps: compare `journalctl --list-boots` with suspend times.
  # - Chrony needs NTS (TCP 4460): check `journalctl -u chronyd` on guest Wi-Fi.

  programs.zoom-us.enable = true;

  environment.systemPackages = with pkgs; [
    # dsnote
    mongodb-compass
    postman
    # remmina
  ];

}
