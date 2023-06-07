{ global, config, lib, ... }:
let
  node = global.nodeIps.${config.networking.hostName}.ts or "127.0.0.1";

  mySubdomains = 
  let
    nginx = builtins.attrNames config.services.nginx.virtualHosts;
    baseDomain = "${config.networking.hostName}.${config.networking.domain}";
  in lib.flatten [ nginx baseDomain ];
in {
  services.dnsmasq = {
    enable = node != null;
    resolveLocalQueries = false;
    extraConfig = ''
      port=53
      domain-needed
      bogus-priv
      no-resolv
      local=/${config.networking.hostName}.${config.networking.domain}/
    '';
  };
  networking.hosts = {
    "${node}" = mySubdomains;
  };
}
