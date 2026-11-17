{ droidloom }:

{
  name = "droidloom";

  meta.timeout = 1200;

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ ./nixos-module.nix ];

      programs.droidloom.enable = true;
      programs.droidloom.package = droidloom;

      users.users.alice = {
        isNormalUser = true;
        uid = 1000;
      };

      environment.systemPackages = [ pkgs.jq ];

      # The test driver has no physical GPU to pass through, so expose QEMU's
      # virtio-gpu; the package under test accepts it through the
      # development-only virtio-gpu patch.
      boot.kernelModules = [
        "drm"
        "virtio_gpu"
      ];

      virtualisation = {
        memorySize = 4096;
        cores = 2;
        diskSize = 8192;
        qemu.options = [
          "-device"
          "virtio-gpu-pci"
        ];
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

    with subtest("the VM exposes a virtio-gpu render node"):
        machine.wait_for_file("/dev/dri/renderD128")
        machine.succeed("grep -qx 'DRIVER=virtio-pci' /sys/class/drm/renderD128/device/uevent")

    with subtest("the host probe runs in the VM"):
        machine.succeed("droidloom-doctor --format json > /tmp/doctor.json || true")
        machine.succeed("jq -e '.schema_version == 1' /tmp/doctor.json")
        machine.succeed("jq -e '.checks[] | select(.id == \"kernel.binderfs\") | .status == \"pass\"' /tmp/doctor.json")
        machine.succeed("jq -e '.checks[] | select(.id == \"kernel.namespaces\") | .status == \"pass\"' /tmp/doctor.json")
        machine.succeed("jq -e '.checks[] | select(.id == \"graphics.render_node\") | .status == \"pass\"' /tmp/doctor.json")
        machine.succeed("droidloomctl --version | grep -q '^droidloomctl '")

    with subtest("setup accepts the virtio-gpu render node"):
        machine.succeed("droidloom-package-helper setup --uid 1000")
        machine.succeed("grep -qx 'DROIDLOOM_RENDER_NODE=/dev/dri/renderD128' /etc/droidloom/runtime.env")
        machine.succeed("jq -e '.render_node == \"/dev/dri/renderD128\" and .graphics_backend == \"drm\"' /etc/droidloom/cell.json")
        machine.succeed("su - alice -c 'droidloomctl gpu' | grep -q 'Virtio GPU'")

    with subtest("the root lifecycle daemon starts from the shipped unit"):
        machine.succeed("systemctl cat droidloomd.service | grep -q '${droidloom}/bin/droidloomd'")
        machine.succeed("systemctl start droidloomd.service")
        machine.wait_for_unit("droidloomd.service")
        machine.wait_for_file("/run/droidloom/control.sock")
        machine.succeed("droidloomctl status | grep -qi 'stopped'")

    with subtest("the cell start stops at the missing presenter bridge"):
        # Android's guest Mesa only ships radeonsi and iris, and the cell needs
        # the session presenter's Denial bridge, so a full boot still needs a
        # supported physical GPU and a running Wayland session. The virtio-gpu
        # patch only takes the host-side GPU policy out of the way.
        machine.fail("su - alice -c 'droidloomctl start --cell'")
        machine.succeed("droidloomctl status | grep -qi 'stopped'")

    with subtest("the user units are installed for the desktop session"):
        machine.succeed("test -f /etc/systemd/user/droidloom.service")
        machine.succeed("grep -q '${droidloom}/bin/droidloom-wayland' /etc/systemd/user/droidloom.service")
        machine.succeed("test -f /etc/systemd/user/droidloom-audio.socket")
        machine.succeed("test -f /etc/systemd/user/droidloom-gpu.socket")
        machine.succeed("su - alice -c 'droidloomctl --help' >/dev/null")
  '';
}
