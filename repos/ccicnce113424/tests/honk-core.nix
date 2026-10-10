{ lib, ... }:
{

  name = "honk-core";

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };

  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.curl ];
      services.nginx = {
        enable = true;
        statusPage = true;
      };
      services.honk-core = {
        enable = true;
        # Nothing exists at this path yet; the service seeds a starter config
        # whose web UI is served from the system profile's doona-web.
        configFile = "/etc/honk/config.dae";
      };
    };

  testScript = ''
    machine.wait_for_unit("nginx.service")
    machine.wait_for_unit("honk.service")

    machine.wait_for_open_port(80)
    machine.wait_for_open_port(9527)

    machine.succeed("curl --fail --max-time 10 http://localhost")
    machine.succeed(
        "curl --fail --max-time 10 -L http://127.0.0.1:9527/"
        " | grep -q '<title>doona</title>'"
    )
  '';

}
