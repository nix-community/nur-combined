{ config, ... }:

{
  services.nginx.virtualHosts."nixcache.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;
    # serverAliases = [ "nixcache" ];
    locations."/".extraConfig = ''
      proxy_pass http://localhost:${toString config.services.nix-serve.port};
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    '';
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."nixcache" = "native";

  sane.services.nixserve.enable = true;
  sane.services.nixserve.sopsFile = ../../../../secrets/servo.yaml;
}
