{ lib, self, ... }:

let
  port = 12345;
  maubotPort = 12346;

  username = "alice";
  password = "verysecretpassword";
in
{
  name = "maubot-exporter";

  nodes.server = { pkgs, ... }: {
    imports = [ self.nixosModules.maubot-exporter ];

    services.maubot-exporter = {
      enable = true;
      inherit port;
      local = true;
      settings = {
        inherit username password;
      };
    };

    services.maubot = {
      enable = true;
      configMutable = true;
      settings = {
        admins.${username} = password;
        server.port = maubotPort;
      };
    };

    systemd.services.maubot.preStart = ''
      mkdir -p /var/lib/maubot/plugins
    '';

    environment.systemPackages = [ pkgs.curl ];
  };

  testScript = ''
    start_all()
    with subtest("start maubot-exporter"):
        server.wait_for_unit("maubot.service")
        server.wait_for_unit("maubot-exporter.service")
        server.wait_for_open_port(${toString port})
        server.wait_for_open_port(${toString maubotPort})

        server.succeed("curl --fail http://localhost:${toString port}/metrics")
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
