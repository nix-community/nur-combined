# VM tests for the Cutefish desktop, in the shape of the NixOS desktop-manager
# tests (nixos/tests/lxqt.nix, cinnamon.nix, mate-wayland.nix): a display
# manager logs the test user in, and the test checks the session that comes up.
#
# The compositor's DRM backend needs a DRM device, so the test replaces QEMU's
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
in
{
  basic = testers.runNixOSTest {
    name = "cutefish";

    nodes.machine = {
      imports = [ cutefishModule ];

      users.users.${user} = {
        isNormalUser = true;
        description = "Alice Foobar";
        password = "foobar";
        uid = uid;
      };

      services.xserver.enable = true;
      services.displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        defaultSession = "cutefish-wayland";
        autoLogin.enable = true;
        autoLogin.user = user;
      };

      services.desktopManager.cutefish.enable = true;

      # Exercise the option: the video player goes, the rest stays.
      environment.cutefish.excludePackages = [ cu.cutefish-video-player ];

      virtualisation.qemu.options = [ "-vga none -device virtio-gpu-pci" ];
      virtualisation.memorySize = 3072;
      virtualisation.cores = 2;

      # gdbus, for the portal check.
      environment.systemPackages = [ pkgs.glib ];
    };

    testScript =
      { ... }:
      ''
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

            machine.sleep(5)
            machine.screenshot("cutefish")
        except Exception:
            diagnostics()
            raise
      '';
  };
}
