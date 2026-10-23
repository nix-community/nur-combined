{
  device = {
    hostname = "pwnbox";
    profile = "vm/qemu";
    users = [
      {
        name = "iamanaws";
        groups = [
          "wheel"
          "input"
        ];
        homeManager.module = "nixos/pwnbox";
      }
    ];
    compositors = [ "hyprland" ];
    stateVersion = "25.11";
    timezone = "UTC";
    locale = "en_US.UTF-8";
  };
}
