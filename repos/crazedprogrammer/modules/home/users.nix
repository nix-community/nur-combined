{ config, pkgs, ... }:

{
  # Disable mutable users.
  users.mutableUsers = false;

  # Allow passwordless sudo for wheel users.
  security.sudo.wheelNeedsPassword = false;

  # User accounts.
  users.extraUsers.casper = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel" "networkmanager" "wireshark" "dialout" "docker"
    ];
    hashedPassword = "$6$ubbEPgKNVlt$OuKWoA.IqJyxxebEdCO8iDIX045XhtxWuhRvZwrFAp5eizycgMOt8rvdVuwwyAsKKtuXjjwOtYGsBJ6zV53SP/";
    home = "/home/casper";
    shell = pkgs.fish;
  };
}
