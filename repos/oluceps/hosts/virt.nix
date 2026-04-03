{
  virtualisation = {
    vmVariant = {
      virtualisation = {
        memorySize = 2048;
        cores = 6;
      };
    };

    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
}
