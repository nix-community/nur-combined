# My blog setup
{ config, lib, ... }:
let
  cfg = config.my.services.blog;
  domain = config.networking.domain;

  makeHostInfo = name: {
    name = "${name}.${domain}";
    value = "/var/www/${name}";
  };

  hostsInfo = [
    {
      name = domain;
      value = "/var/www/blog";
    }
  ] ++ builtins.map makeHostInfo [ "cv" "dev" "key" ];

  hosts = builtins.listToAttrs hostsInfo;

  makeVirtualHost = with lib.attrsets;
    name: root: nameValuePair "${name}" {
      forceSSL = true;
      useACMEHost = domain;
      inherit root;
      # Make my blog the default landing site
      default = (name == domain);
    };
in
{
  options.my.services.blog = {
    enable = lib.mkEnableOption "Blog hosting";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = with lib.attrsets;
      mapAttrs' makeVirtualHost hosts;
  };
}
