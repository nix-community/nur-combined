{ ... }:
{
  enable = true;
  collector = {
    enable = true;
    settings.api.endpoint = "http://localhost:8080";
  };

  settings = {
    web.listen = {
      port = 8080;
      host = "0.0.0.0";
    };

    openFirewall = true;

    notify = {
      urls = [ "ntfy://ntfy.nyaw.xyz/info" ];
    };
  };
}
