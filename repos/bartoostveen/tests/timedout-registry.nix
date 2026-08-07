{ lib, self, ... }:

let
  port = 12345;
in
{
  name = "timedout-registry";

  nodes.server = { pkgs, ... }: {
    imports = [ self.nixosModules.timedout-registry ];
    services.timedout-registry = {
      enable = true;
      settings.listen = "127.0.0.1:${toString port}";
      entries = {
        example_slug = {
          import_path = "go.example.com/example_slug";
          repo_url = "https://git.example.com/example_user/example_repo";
        };
      };
    };
    environment.systemPackages = [ pkgs.curl ];
  };

  testScript = ''
    start_all()
    with subtest("start timedout-registry"):
        server.wait_for_unit("timedout-registry.service")
        server.wait_for_open_port(${toString port})

        server.succeed("curl --fail -H go.example.com http://localhost:${toString port}/example_slug?go-get=1")
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
