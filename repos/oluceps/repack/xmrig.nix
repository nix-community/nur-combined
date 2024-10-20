{
  reIf,
  data,
  config,
  ...
}:
reIf {
  systemd.services.xmrig.serviceConfig = {
    CPUSchedulingPolicy = "idle";
    Nice = 14;
  };
  services.xmrig = {
    enable = false;
    settings = {
      autosave = true;
      opencl = false;
      cuda = false;
      cpu = {
        enable = true;
        max-threads-hint = 95;
      };
      pools = [
        {
          url = "pool.supportxmr.com:443";
          user = data.xmrAddr;
          keepalive = true;
          tls = true;
          pass = config.networking.hostName;
        }
      ];
    };
  };
}
