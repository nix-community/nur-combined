{
  config,
  vacuModules,
  vaculib,
  ...
}:
{
  imports = [ vacuModules.garage ];
  vacu.garage = {
    rpcPort = 26950;
    dataDir = "/xstore/garage-data";
    capacity = "2.5T";
  };

  services.garage.settings = {
    block_ram_buffer_max = "1G";
    s3_api.root_domain = ".s3.garage.solis.shelvacu.com";
  };

  users.users.${config.services.caddy.user}.extraGroups = [
    "garage-sockets"
    "garage"
  ];

  systemd.tmpfiles.settings."10-nix"."/xstore/garage-data".d = {
    user = "garage";
    group = "garage";
    mode = vaculib.accessModeStr { user = "all"; };
  };

  services.caddy.virtualHosts = {
    "s3.garage.solis.shelvacu.com".extraConfig = ''
      reverse_proxy unix/${config.vacu.garage.sockets.s3}
    '';
    "admin.garage.solis.shelvacu.com".extraConfig = ''
      reverse_proxy unix/${config.vacu.garage.sockets.admin}
    '';
  };
}
