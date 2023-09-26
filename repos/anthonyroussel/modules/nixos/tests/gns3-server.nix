{ pkgs, ... }:

pkgs.testers.runNixOSTest ({ pkgs, lib, ... }: {
  name = "gns3-server";
  meta.maintainers = [ lib.maintainers.anthonyroussel ];

  nodes.machine =
    { ... }:
    {
      services.gns3-server = {
        enable = true;
        auth = {
          enable = true;
          user = "user";
          passwordFile = pkgs.writeText "gns3-auth-password-file" "password";
        };
        dynamips.enable = true;
        ubridge.enable = true;
        vpcs.enable = true;
      };
    };

  testScript = let
    createProject = pkgs.writeText "createProject.json" (builtins.toJSON {
      name = "test_project";
    });
  in
  ''
    start_all()

    machine.wait_for_unit("gns3-server.service")
    machine.wait_for_open_port(3080)

    with subtest("server is listening"):
      machine.succeed("curl -sSfL -u user:password http://localhost:3080/v2/version")

    with subtest("create dummy project"):
      machine.succeed("curl -sSfL -u user:password http://localhost:3080/v2/projects -d @${createProject}")

    with subtest("logging works"):
      log_path = "/var/log/gns3/server.log"
      machine.wait_for_file(log_path)
  '';
})
