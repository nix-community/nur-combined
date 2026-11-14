{
  name = "hydro";

  containers.machine = { config, ... }: {
    imports = import ../modules/module-list.nix;

    services.hydro = {
      enable = true;
      database.createLocally = true;
      addons = [
        "${config.services.hydro.package}/lib/hydro/packages/ui-default"
        "${config.services.hydro.package}/lib/hydro/packages/hydrojudge"
      ];
    };

    services.hydro-sandbox.enable = true;

    systemd.services.hydro = {
      after = [ "hydro-sandbox.service" ];
      wants = [ "hydro-sandbox.service" ];
    };

    services.caddy = {
      enable = true;
      openFirewall = true;
      virtualHosts."http://".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.hydro.port}
      '';
    };
  };

  testScript = ''
    import json
    import shlex

    def hydro_json(expression):
        script = f"return JSON.stringify(await ({expression}))"
        output = machine.succeed(f"hydrooj cli execute {shlex.quote(script)}")
        return json.loads(output)

    machine.wait_for_unit("default.target")
    machine.wait_until_succeeds("curl http://localhost | grep 'Hydro is running normally'")

    uid = hydro_json('UserModel.create("alice@example.com", "alice", "password", 2)')
    t.assertEqual(uid, 2)

    src = """\
      #include <iostream>
      int main() {
        int a, b;
        std::cin >> a >> b;
        std::cout << a + b << "\\\\n";
      }
    """

    record_id = hydro_json(f'RecordModel.add("system", 1, 2, "cc", `{src}`, true)')

    def get_record():
        return hydro_json(
            f'RecordModel.get("system", new ObjectId({json.dumps(record_id)}))'
        )

    # STATUS_WAITING, STATUS_JUDGING, STATUS_COMPILING, STATUS_FETCHED
    retry(lambda _: get_record()["status"] not in (0, 20, 21, 22))
    record = get_record()

    t.assertEqual(record["_id"], record_id)
    t.assertEqual(record["status"], 1)
    t.assertEqual(record["score"], 100)
  '';
}
