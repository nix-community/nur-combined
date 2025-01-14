{
  lib,
  nixosTest,
  sharkey,
}:

nixosTest (
  _:
  let
    port = 61812;
  in
  {
    name = "sharkey";

    meta.maintainers = [ lib.maintainers.federicoschonborn ];

    nodes.machine = {
      services.misskey = {
        enable = true;
        package = sharkey;
        settings = {
          url = "http://misskey.local";
          inherit port;
        };
        database.createLocally = true;
        redis.createLocally = true;
      };
    };

    testScript = ''
      machine.wait_for_unit("misskey.service")
      machine.wait_for_open_port(${toString port})
      machine.succeed("curl --fail http://localhost:${toString port}/")
    '';
  }
)
