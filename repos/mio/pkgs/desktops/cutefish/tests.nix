# VM tests for the Cutefish desktop, in the shape of the NixOS desktop-manager
# tests (nixos/tests/lxqt.nix, cinnamon.nix, mate-wayland.nix): a display
# manager logs the test user in, and the test checks the session that comes up.
# The `dm` and `greeter` tests do the same for cutefish-dm itself, once logging
# in automatically and once through its login screen.
#
# The compositor's DRM backend needs a DRM device, so the tests replace QEMU's
# default VGA adapter with virtio-gpu the way the Wayland MATE and Sway tests
# do; the software renderer then draws the screenshot.
{
  pkgs,
  testers,
  cutefishModule,
}:

let
  # Same packages the module builds when the NUR overlay is not applied.
  cu = pkgs.callPackage ./scope.nix { };

  user = "alice";
  uid = 1000;
  sessionEnv = "XDG_RUNTIME_DIR=/run/user/${toString uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString uid}/bus";

  # Shared by every test.
  nodeBase = {
    imports = [ cutefishModule ];

    users.users.${user} = {
      isNormalUser = true;
      description = "Alice Foobar";
      password = "foobar";
      uid = uid;
    };

    services.xserver.enable = true;
    services.desktopManager.cutefish.enable = true;

    # Exercise the option: the video player goes, the rest stays.
    environment.cutefish.excludePackages = [ cu.cutefish-video-player ];

    virtualisation.qemu.options = [ "-vga none -device virtio-gpu-pci" ];
    virtualisation.memorySize = 3072;
    virtualisation.cores = 2;

    # gdbus, for the portal check.
    environment.systemPackages = [ pkgs.glib ];
  };

  # Python helpers shared by the test scripts. `subtest` and `machine` come
  # from the test driver.
  prelude = ''
    import shlex

    def user(command):
        return "su - " + "${user}" + " -c " + shlex.quote("${sessionEnv} " + command)

    def diagnostics():
        for command in [
            "journalctl -b --no-pager -o cat | tail -300",
            "journalctl -b --no-pager -o cat | grep -iE 'cutefish|compositor|libseat|drm|egl|session' | tail -120",
            "ls -la /run/user/${toString uid} || true",
            "coredumpctl --no-pager || true",
            user("systemctl --user status graphical-session.target --no-pager || true"),
        ]:
            status, output = machine.execute(command)
            print(f"Diagnostic (status {status}): {command}\\n{output}")

        # Run the compositor's headless backend by hand: its stderr says
        # whether the binary works at all.
        machine.execute("mkdir -p /tmp/cfrun && chown ${user} /tmp/cfrun && chmod 700 /tmp/cfrun")
        machine.execute(
            "su - ${user} -c 'XDG_RUNTIME_DIR=/tmp/cfrun cutefish-compositor --no-drm --socket probe-0 > /tmp/cf-compositor.log 2>&1 &'"
        )
        machine.sleep(4)
        status, output = machine.execute("cat /tmp/cf-compositor.log; ls -l /tmp/cfrun")
        print(f"Headless compositor probe (status {status}):\\n{output}")

    def check_dm():
        with subtest("cutefish-dm is the display manager"):
            machine.succeed("systemctl is-active cutefish-dm.service")
            machine.succeed("pgrep -f '[c]utefish-dm'")
            machine.succeed("readlink -f /etc/systemd/system/display-manager.service | grep -q cutefish-dm")
            machine.succeed("test -f /etc/pam.d/cutefish-dm")

        with subtest("Cutefish session is registered with the display manager"):
            machine.succeed("test -x /run/current-system/sw/bin/cutefish-wayland-session")
            machine.succeed("grep -q '^DesktopNames=Cutefish;' /run/current-system/sw/share/wayland-sessions/cutefish-wayland.desktop")

    def check_autologin():
        with subtest("Autologin is configured for the test user"):
            machine.succeed("grep -q '^User=${user}$' /etc/cutefish-dm.conf")
            machine.succeed("grep -q '^Session=cutefish-wayland$' /etc/cutefish-dm.conf")

        with subtest("Autologin starts the Wayland session"):
            machine.wait_for_file("/run/user/${toString uid}/cutefish-0", timeout=60)
            machine.wait_until_succeeds("pgrep -f '[c]utefish-compositor --socket'", timeout=120)
            machine.wait_until_succeeds("pgrep -f '[b]in/cutefish-session'", timeout=120)

    def check_session():
        with subtest("logind records a Wayland user session"):
            sid = machine.succeed("loginctl list-sessions --no-legend | awk '/${user}/ {print $1; exit}'").strip()
            machine.succeed(f"loginctl show-session {sid} -p Type | grep -q '^Type=wayland$'")
            machine.succeed(f"loginctl show-session {sid} -p Class | grep -q '^Class=user$'")

        with subtest("Shell and session services run"):
            for name in ["cutefish-filemanager", "cutefish-services", "cutefish-polkit-agent"]:
                pattern = "[" + name[0] + "]" + name[1:]
                machine.wait_until_succeeds(f"pgrep -f '{pattern}'", timeout=120)

        with subtest("The session starts graphical-session.target"):
            machine.wait_until_succeeds(
                user("systemctl --user is-active graphical-session.target"), timeout=30
            )

        with subtest("The session environment matches the desktop"):
            compositor = machine.succeed("pgrep -f '[c]utefish-compositor --socket'").split()[0]
            environ = f"xargs --null --max-args=1 echo < /proc/{compositor}/environ"
            machine.succeed(f"{environ} | grep -x 'XDG_CURRENT_DESKTOP=Cutefish'")
            machine.succeed(f"{environ} | grep -x 'XDG_SESSION_DESKTOP=Cutefish'")
            machine.succeed(f"{environ} | grep -x 'DESKTOP_SESSION=Cutefish'")
            machine.succeed(f"{environ} | grep -x 'XDG_SESSION_TYPE=wayland'")
            machine.succeed(f"{environ} | grep -x 'WAYLAND_DISPLAY=cutefish-0'")

        with subtest("xdg-desktop-portal uses the Cutefish backend"):
            machine.succeed(
                user("gdbus call --session --dest org.freedesktop.portal.Desktop "
                     "--object-path /org/freedesktop/portal/desktop "
                     "--method org.freedesktop.portal.Settings.Read "
                     "org.freedesktop.appearance color-scheme")
            )
            machine.wait_until_succeeds("pgrep -f '[x]dg-desktop-portal-cutefish'", timeout=120)

        with subtest("environment.cutefish.excludePackages drops only the video player"):
            machine.fail("test -e /run/current-system/sw/bin/cutefish-video-player")
            machine.succeed("test -x /run/current-system/sw/bin/cutefish-terminal")
            machine.succeed("test -x /run/current-system/sw/bin/cutefish-settings")

        with subtest("Nothing in the session has coredumped"):
            machine.fail("coredumpctl --json=short | grep -Ei 'cutefish|skia'")
  '';
in
{
  basic = testers.runNixOSTest {
    name = "cutefish";

    nodes.machine = pkgs.lib.recursiveUpdate nodeBase {
      services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        defaultSession = "cutefish-wayland";
        autoLogin.enable = true;
        autoLogin.user = user;
      };
    };

    testScript =
      { ... }:
      prelude
      + ''

        try:
            start_all()
            machine.wait_for_unit("display-manager.service")

            with subtest("Cutefish session is registered with the display manager"):
                machine.succeed("test -x /run/current-system/sw/bin/cutefish-wayland-session")
                machine.succeed("grep -q '^DesktopNames=Cutefish;' /run/current-system/sw/share/wayland-sessions/cutefish-wayland.desktop")
                machine.succeed("grep -q '^Exec=/nix/store/' /run/current-system/sw/share/wayland-sessions/cutefish-wayland.desktop")
                machine.succeed("grep -q '^TryExec=cutefish-compositor' /run/current-system/sw/share/wayland-sessions/cutefish-wayland.desktop")

            with subtest("SDDM autologin starts the Wayland session"):
                machine.wait_for_file("/run/user/${toString uid}/cutefish-0", timeout=40)
                machine.wait_until_succeeds("pgrep -f '[c]utefish-compositor --socket'", timeout=60)
                machine.wait_until_succeeds("pgrep -f '[b]in/cutefish-session'", timeout=60)

            check_session()

            machine.sleep(5)
            machine.screenshot("cutefish")
        except Exception:
            diagnostics()
            raise
      '';
  };

  dm = testers.runNixOSTest {
    name = "cutefish-dm";

    nodes.machine = pkgs.lib.recursiveUpdate nodeBase {
      services.displayManager = {
        cutefish-dm.enable = true;
        autoLogin.enable = true;
        autoLogin.user = user;
      };
    };

    testScript =
      { ... }:
      prelude
      + ''

        try:
            start_all()
            machine.wait_for_unit("display-manager.service")

            check_dm()
            check_autologin()
            check_session()

            machine.sleep(5)
            machine.screenshot("cutefish-dm")
        except Exception:
            diagnostics()
            raise
      '';
  };

  greeter = testers.runNixOSTest {
    name = "cutefish-dm-greeter";

    nodes.machine = pkgs.lib.recursiveUpdate nodeBase {
      services.displayManager.cutefish-dm.enable = true;
    };

    testScript =
      { ... }:
      prelude
      + ''

        try:
            start_all()
            machine.wait_for_unit("display-manager.service")

            check_dm()

            with subtest("The greeter PAM service and user exist"):
                machine.succeed("test -f /etc/pam.d/cutefish-dm-greeter")
                machine.succeed("id cutefish-greeter")

            with subtest("The login screen runs on the compositor"):
                machine.wait_until_succeeds("pgrep -f '[c]utefish-compositor --login'", timeout=120)

            with subtest("logind records a greeter session"):
                # The greeter user also has a manager-early session from its user
                # manager; the greeter one is the session the compositor runs in.
                sids = machine.succeed("loginctl list-sessions --no-legend | awk '/cutefish-greeter/ {print $1}'").split()
                sid = next(
                    s
                    for s in sids
                    if machine.execute(f"loginctl show-session {s} -p Class")[1].strip() == "Class=greeter"
                )
                machine.succeed(f"loginctl show-session {sid} -p Type | grep -q '^Type=wayland$'")

            machine.sleep(5)
            machine.screenshot("cutefish-dm-greeter")
        except Exception:
            diagnostics()
            raise
      '';
  };

  # The same login screen with the boot splash enabled, as on a normal boot.
  # plymouth owns the DRM device until cutefish-dm takes it over, and the
  # daemon only finds plymouth through PATH; without it the compositor's
  # TakeDevice fails with EBUSY and the login screen restart-loops.
  splash = testers.runNixOSTest {
    name = "cutefish-dm-splash";

    nodes.machine = pkgs.lib.recursiveUpdate nodeBase {
      services.displayManager.cutefish-dm.enable = true;
      boot.plymouth.enable = true;
      # cutefish-dm.service conflicts with plymouth-quit.service, so a real
      # boot still has the splash up when the daemon starts. Keep it that way
      # here instead of letting the VM quit plymouth first.
      systemd.services.plymouth-quit.wantedBy = pkgs.lib.mkForce [ ];
    };

    testScript =
      { ... }:
      prelude
      + ''

        try:
            start_all()

            with subtest("The boot splash is up"):
                machine.wait_for_unit("plymouth-start.service")
                machine.succeed("${pkgs.plymouth}/bin/plymouth --ping")

            machine.wait_for_unit("display-manager.service")

            check_dm()

            with subtest("The login screen takes the display from the boot splash"):
                # plymouth owns the DRM device until the daemon finds it in PATH
                # and quits it; otherwise this fails with EBUSY.
                machine.wait_until_succeeds("pgrep -f '[c]utefish-compositor --login'", timeout=120)
                machine.wait_until_fails("${pkgs.plymouth}/bin/plymouth --ping", timeout=60)

            machine.sleep(5)
            machine.screenshot("cutefish-dm-splash")
        except Exception:
            diagnostics()
            raise
      '';
  };
}
