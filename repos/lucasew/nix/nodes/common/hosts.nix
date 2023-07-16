{ global, config, lib, ... }:
let
  node = global.nodeIps.${config.networking.hostName}.ts or "127.0.0.1";

  nginxDomains = builtins.attrNames config.services.nginx.virtualHosts;
  baseDomain = "${config.networking.hostName}.${config.networking.domain}";
  allMySubdomains = lib.flatten [ nginxDomains baseDomain ];
in {
  services.nginx.enable = lib.mkDefault ((builtins.length nginxDomains) > 0);
  services.dnsmasq = {
    enable = node != null;
    resolveLocalQueries = false;
    extraConfig = ''
      port=53
      domain-needed
      bogus-priv
      no-resolv
      local=/${config.networking.hostName}.${config.networking.domain}/
      bind-interfaces
      except-interface=virbr0
    '';
  };
  networking.hosts = {
    "${node}" = allMySubdomains;
  };
}
