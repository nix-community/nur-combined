{
  reIf,
  data,
  config,
  ...
}:
reIf {
  services.xmrig = {
    enable = true;
    settings = {
      autosave = true;
      opencl = false;
      cuda = false;
      cpu = {
        enable = true;
        max-threads-hint = 75;
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
