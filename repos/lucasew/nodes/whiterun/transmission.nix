{ ... }: {
  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      incomplete-dir = "/tmp/transmission/incomplete";
    };
  };
}
