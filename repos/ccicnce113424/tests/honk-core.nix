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
        config = ''
          global {
              # the test network; hosts its traffic through the WAN hooks
              wan_interface: 'eth1'
              tproxy_port: 12345
              nfqueue_enable: false
          }

          experimental {
              native_api {
                  enabled: true
                  listen: '127.0.0.1:9527'
                  allow_anonymous_loopback: true
                  ui: 'embedded'
              }
          }

          routing {
              fallback: direct
          }
        '';
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
