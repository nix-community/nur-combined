{ droidloom }:

{
  name = "droidloom";

  meta.timeout = 1200;

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ ./nixos-module.nix ];

      programs.droidloom.enable = true;

      users.users.alice = {
        isNormalUser = true;
        uid = 1000;
      };

      environment.systemPackages = [ pkgs.jq ];

      virtualisation = {
        memorySize = 4096;
        cores = 2;
        diskSize = 8192;
      };

      system.stateVersion = "26.11";
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    with subtest("the package payload is installed"):
        machine.succeed("test -f ${droidloom}/lib/droidloom/images/images/system.img")
        machine.succeed("test -f ${droidloom}/lib/droidloom/images/images/system_ext.img")
        machine.succeed("test -f ${droidloom}/lib/droidloom/images/images/product.img")
        machine.succeed("test -f ${droidloom}/lib/droidloom/images/images/vendor.raw.img")
        machine.succeed("test -f ${droidloom}/lib/droidloom/current/bin/droidloom-android-init")
        machine.succeed("test -f ${droidloom}/lib/droidloom/current/framework/services.jar")

    with subtest("the host probe runs in the VM"):
        # The probe exits non-zero while its blocking checks (such as the
        # graphics render node) fail, which a VM without a supported GPU does.
        machine.succeed("droidloom-doctor --format json > /tmp/doctor.json || true")
        machine.succeed("jq -e '.schema_version == 1' /tmp/doctor.json")
        machine.succeed("jq -e '.checks[] | select(.id == \"kernel.binderfs\") | .status == \"pass\"' /tmp/doctor.json")
        machine.succeed("jq -e '.checks[] | select(.id == \"kernel.namespaces\") | .status == \"pass\"' /tmp/doctor.json")
        machine.succeed("droidloomctl --version | grep -q '^droidloomctl '")

    with subtest("the root lifecycle daemon starts from the shipped unit"):
        machine.succeed("systemctl cat droidloomd.service | grep -q '${droidloom}/bin/droidloomd'")
        machine.succeed("systemctl start droidloomd.service")
        machine.wait_for_unit("droidloomd.service")
        machine.wait_for_file("/run/droidloom/control.sock")
        machine.succeed("droidloomctl status | grep -qi 'stopped'")

    with subtest("the user units are installed for the desktop session"):
        machine.succeed("test -f /etc/systemd/user/droidloom.service")
        machine.succeed("grep -q '${droidloom}/bin/droidloom-wayland' /etc/systemd/user/droidloom.service")
        machine.succeed("test -f /etc/systemd/user/droidloom-audio.socket")
        machine.succeed("test -f /etc/systemd/user/droidloom-gpu.socket")
        machine.succeed("su - alice -c 'droidloomctl --help' >/dev/null")
  '';
}
