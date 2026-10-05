let
  pkgs = import <nixpkgs> { };
  modules = import ../modules { };
in
pkgs.testers.runNixOSTest {
  name = "fail2ban-rs-service-test";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ modules.fail2ban-rs ];

      services.fail2ban-rs = {
        enable = true;
        settings = {
          jail.test = {
            log_path = "/var/log/test.log";
            filter = [ "test fail from <HOST>" ];
            max_retry = 1;
            find_time = "1m";
            ban_time = "1m";
            # script backend avoids needing firewall tools in the VM
            backend.script = {
              ban_cmd = "touch /var/lib/fail2ban-rs/banned";
              unban_cmd = "true";
            };
          };
        };
      };
    };

  testScript = ''
    # 1. log file must exist before the watcher can tail it
    machine.succeed("touch /var/log/test.log")

    # 2. wait for the service to start
    machine.wait_for_unit("fail2ban-rs.service")

    # 3. CLI talks to the daemon via the /etc config
    machine.succeed("fail2ban-rs status")

    # 4. a matching log line triggers a ban through the script backend
    machine.succeed("echo 'test fail from 1.2.3.4' >> /var/log/test.log")
    machine.wait_until_succeeds("test -f /var/lib/fail2ban-rs/banned")

    print(machine.succeed("journalctl -u fail2ban-rs --no-pager"))
  '';
}
