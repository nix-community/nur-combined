{ ... }: {
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      allow 192.168.69.0/24;
      allow 127.0.0.1;
      allow ::1;
      deny all;
    '';
  };

}
