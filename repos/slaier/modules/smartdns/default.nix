{
  services.smartdns = {
    enable = true;
    settings = {
      bind = [ ":53 -group office" ];
      bind-tcp = [ ":53 -group home" ];
      server = [ "114.114.114.114 -bootstrap-dns" ];
      server-https = [
        "https://doh.pub/dns-query -group office -exclude-default-group"
        "https://dns.alidns.com/dns-query -group office -exclude-default-group"
        "https://dns.cloudflare.com/dns-query -group home -exclude-default-group"
        "https://public.dns.iij.jp/dns-query -group home -exclude-default-group"
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [ 53 ];
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
  environment.sessionVariables = {
    RES_OPTIONS = "use-vc";
  };
}
