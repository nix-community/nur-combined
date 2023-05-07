{ pkgs, ... }: {
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "aria2"
      "docker"
      "vboxusers"
      "wheel"
    ];
  };
}
