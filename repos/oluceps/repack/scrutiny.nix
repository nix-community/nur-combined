{ reIf, ... }:
reIf {
  systemd.services.scrutiny.after = [ "bird.service" ];
  services.scrutiny = {
    enable = true;
    collector = {
      enable = true;
      settings.api.endpoint = "https://scrutiny.nyaw.xyz";
    };

    settings = {
      web.listen = {
        port = 8090;
        host = "0.0.0.0";
      };

      openFirewall = false;

      # notify = {
      #   urls = [ "ntfy://ntfy.nyaw.xyz/critical?auth=QmVhcmVyIHRrXzFkZTlmYXdic3g1NGFweWVmbDZ3OWFtOGg5Mmpn" ];
      # };
    };
  };
}
