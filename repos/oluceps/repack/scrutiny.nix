{ reIf, ... }:
reIf {
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

      openFirewall = true;

      notify = {
        urls = [ "ntfy://ntfy.nyaw.xyz/crit?auth=QmVhcmVyIHRrXzFkZTlmYXdic3g1NGFweWVmbDZ3OWFtOGg5Mmpn" ];
      };
    };
  };
}
