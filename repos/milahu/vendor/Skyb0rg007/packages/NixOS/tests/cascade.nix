{
  name = "cascade";
  meta.timeout = 120;

  nodes.machine.services.cascade.enable = true;

  testScript = ''
    machine.start()
    machine.wait_for_unit("cascaded.service")

    with subtest("health check"):
      machine.wait_until_succeeds("cascade health")

    with subtest("zone list"):
      machine.succeed("cascade zone list")
  '';
}
