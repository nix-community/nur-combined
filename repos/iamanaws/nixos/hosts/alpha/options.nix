{
  device = {
    system = "aarch64-linux";
    hostname = "alpha";
    profile = "server";
    users = [
      {
        name = "iamanaws";
        groups = [
          "wheel"
          "input"
          "networkmanager"
        ];
        homeManager.enable = false;
      }
    ];
    stateVersion = "25.11";
    timezone = "UTC";
    locale = "en_US.UTF-8";
  };
}
