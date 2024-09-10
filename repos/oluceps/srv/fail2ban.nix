_: {
  enable = true;
  maxretry = 5;
  ignoreIP = [
    "127.0.0.0/8"
    "10.0.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];
  attach.services.nginx.enable = true;
}
