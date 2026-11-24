{ config, pkgs, ... }:
{
  name = "ruroco";
  nodes.machine = { config, pkgs, ... }: {
    # TODO must change this for nixpkgs?
    imports = [ ./ruroco.nix ];
    users.groups.ruroco = {};
    users.users.ruroco = {
      isSystemUser = true;
      group = "ruroco";
      shell = "/bin/false";
    };
    services.ruroco = {
      enable = true;
      autostart = false;
      stateDir = "/var/lib/ruroco";
      user = "ruroco";
      group = "ruroco";
      ips = ["127.0.0.1"];
      commands = { default = "touch /tmp/start.test /tmp/stop.test"; };
    };
  };

  testScript = ''
    machine.succeed("ruroco-client gen > /var/lib/ruroco/ruroco.key")
    machine.succeed("chown ruroco:ruroco /var/lib/ruroco/ruroco.key")
    machine.succeed("chmod 400 /var/lib/ruroco/ruroco.key")
    machine.systemctl("start ruroco-commander.service")
    machine.succeed("ruroco-client send -a 127.0.0.1:80 -k $(cat /var/lib/ruroco/ruroco.key)")
    machine.sleep(3)
    machine.succeed("test -f /tmp/start.test")
    machine.succeed("test -f /tmp/stop.test")
  '';
  # machine.execute("strace -f -v -s 1024 -e trace=execve -o /tmp/commander.trace -p $(pidof ruroco-commander) >&2 &")
  # machine.copy_from_vm("/tmp/commander.trace", "./")
}
