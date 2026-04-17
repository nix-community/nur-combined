{
  flake.modules.nixos.scrutiny = {
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
      };
    };
  };
}
