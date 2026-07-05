{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    sing_box_server_ip = { };
    sing_box_server_name = { };
    sing_box_server_uuid = { };
    sing_box_server_path = { };
  };
  services.sing-box = {
    enable = true;
    settings = {
      dns = {
        servers = [
          {
            type = "udp";
            tag = "google";
            server = "8.8.8.8";
          }
        ];
        strategy = "ipv4_only";
      };
      certificate.store = "mozilla";
      inbounds = [
        {
          type = "mixed";
          tag = "mixed-in";
          listen = "0.0.0.0";
          listen_port = 7890;
        }
      ];
      outbounds = [
        {
          type = "vless";
          tag = "proxy";
          server._secret = config.sops.secrets.sing_box_server_ip.path;
          server_port = 443;
          uuid._secret = config.sops.secrets.sing_box_server_uuid.path;
          tls = {
            enabled = true;
            server_name._secret = config.sops.secrets.sing_box_server_name.path;
          };
          multiplex.enabled = true;
          transport = {
            type = "httpupgrade";
            path._secret = config.sops.secrets.sing_box_server_path.path;
            headers.Host._secret = config.sops.secrets.sing_box_server_name.path;
          };
        }
      ];
    };
  };
  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;
    proxies = {
      sing-box = {
        enable = true;
        host = "127.0.0.1";
        port = 7890;
        type = "http";
      };
    };
    proxyDNS = false;
  };
}
