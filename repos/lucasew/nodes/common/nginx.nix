{ ... }: {
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      allow 192.168.69.0/24;
      deny all;
    '';
  };

}
