{
  enable = true;
  securityType = "user";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = dragonite
    netbios name = dragonite
    security = user 
    hosts allow = 192.168.1.0/24 192.168.8.0/24 localhost
    hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
  shares = {
    isos = {
      path = "/mnt/zfs/isos";
      browseable = "yes";
      "read only" = true;
      "guest ok" = "yes";
      comment = "Public ISO Share";
    };
  };
}
