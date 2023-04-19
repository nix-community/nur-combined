{ config, lib, ... }:
let
  node = {
    riverwood = "100.108.254.101";
    whiterun = "100.85.38.19";
  }."${config.networking.hostName}";

  mySubdomains = 
  let
    nginx = builtins.attrNames config.services.nginx.virtualHosts;
  in lib.flatten [ nginx ];
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      port=5353
      domain-needed
      bogus-priv
      no-resolv
      local=/${config.networking.domain}/
    '';
  };
  networking.hosts = {
    "${node}" = mySubdomains;
  };
}
