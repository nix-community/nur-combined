{
  package,
  pkgs,
  testers,
  runCommand,
  callPackage,
}:
let
  images = callPackage ./robotnix-image.nix { };
  notificationReceiver = pkgs.writeShellScriptBin "miodroid-notification-receiver" ''
    exec ${
      pkgs.python3.withPackages (p: [
        p.dbus-python
        p.pygobject3
      ])
    }/bin/python3 ${./tests/notifications.py}
  '';
  # The standard Nixpkgs kernel already enables Binderfs, user namespaces,
  # FUSE and the LXC network features. Test the kernel users actually install.
  binderKernel = pkgs.linuxPackages;
  mkTest =
    {
      rootless,
      strategy ? "overlay",
    }:
    testers.runNixOSTest {
      name = "miodroid-${if rootless then "rootless-${strategy}" else "rootful"}";
      nodes.machine = { lib, ... }: {
        imports = [ ../../../modules/miodroid.nix ];
        virtualisation.miodroid = lib.mkIf (!rootless) {
          enable = true;
          inherit package;
          imagePackage = images;
        };
        virtualisation.miodroid-rootless = lib.mkIf rootless {
          enable = true;
          inherit package;
          imagePackage = images;
          imageStrategy = strategy;
        };
        boot.kernelPackages = binderKernel;
        boot.kernelModules = [ "binder_linux" ];
        virtualisation.memorySize = 6144;
        virtualisation.cores = 4;
        virtualisation.diskSize = 24576;
        users.users.alice = {
          isNormalUser = true;
          extraGroups = [
            "video"
            "render"
          ]
          ++ lib.optionals rootless [
            "miodroid"
            "lxc-user"
          ];
          subUidRanges = [
            {
              startUid = 100000;
              count = 2097152;
            }
          ];
          subGidRanges = [
            {
              startGid = 100000;
              count = 2097152;
            }
          ];
        };
        # Android asks for best-effort scheduling priorities. Give the test
        # login the same limits as a desktop multimedia session.
        security.pam.loginLimits = [
          {
            domain = "alice";
            item = "nice";
            type = "-";
            value = "-20";
          }
          {
            domain = "alice";
            item = "rtprio";
            type = "-";
            value = "40";
          }
        ];
        systemd.user.settings.Manager = {
          DefaultLimitNICE = "-20";
          DefaultLimitRTPRIO = "40";
        };
        systemd.user.services.miodroid-test-notification-receiver = {
          description = "Miodroid VM notification test receiver";
          serviceConfig = {
            ExecStart = "${notificationReceiver}/bin/miodroid-notification-receiver";
            Restart = "on-failure";
            StandardOutput = "append:/tmp/miodroid-notifications.log";
            StandardError = "append:/tmp/miodroid-notifications.log";
          };
        };
        networking.firewall.interfaces.lxcbr0.allowedTCPPorts = [ 8080 ];
        environment.systemPackages = [
          package
          pkgs.weston
          pkgs.pulseaudio
          pkgs.wl-clipboard
          pkgs.python3
          notificationReceiver
        ];
        systemd.user.services.miodroid-test-container = lib.mkIf rootless {
          serviceConfig = {
            ExecStart = "${package}/bin/miodroid --details-to-stdout container start";
            Delegate = true;
            Type = "dbus";
            BusName = "id.miodro.Container";
            Environment = [
              "MIODROID_ROOTLESS=1"
              "MIODROID_WORK=/home/alice/.local/share/miodroid"
              "MIODROID_ROOTLESS_OVERLAY=${if strategy == "overlay" then "1" else ""}"
            ];
          };
        };
      };
      testScript = ''
        import shlex
        import time

        start_all()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("loginctl enable-linger alice")
        machine.wait_for_unit("user@1000.service")
        machine.wait_until_succeeds("test -S /run/user/1000/bus")
        env = {
            "XDG_RUNTIME_DIR": "/run/user/1000",
            "DBUS_SESSION_BUS_ADDRESS": "unix:path=/run/user/1000/bus",
            "WAYLAND_DISPLAY": "wayland-0",
            "PULSE_SERVER": "unix:/run/user/1000/pulse/native",
        }
        rootless = ${if rootless then "True" else "False"}
        if rootless:
            env.update(MIODROID_ROOTLESS="1", MIODROID_WORK="/home/alice/.local/share/miodroid",
                       MIODROID_ROOTLESS_OVERLAY="${if strategy == "overlay" then "1" else ""}")
        user_prefix = "runuser -u alice -- env " + " ".join(shlex.quote(k + "=" + v) for k, v in env.items()) + " "
        def user(command):
            return user_prefix + "sh -c " + shlex.quote(command)
        def android(command, uid=None):
            prefix = user_prefix if rootless else ""
            identity = " --uid " + str(uid) if uid is not None else ""
            return prefix + "miodroid --details-to-stdout shell" + identity + " -- /system/bin/sh -c " + shlex.quote(command) + " 2>&1 < /dev/null"
        def wait_for_android():
            for attempt in range(150):
                status, _ = machine.execute(android("test $(getprop sys.boot_completed) = 1"))
                if status == 0:
                    return
                if attempt == 30:
                    probe = android("getprop sys.boot_completed; getprop init.svc.servicemanager; getprop init.svc.zygote; getprop init.svc.bootanim; ps -A; ls -l /dev/binder* /dev/binderfs/*")
                    probe_status, output = machine.execute(probe)
                    print(f"Android early-boot probe (status {probe_status}):\n{output}")
                work = "/home/alice/.local/share/miodroid" if rootless else "/var/lib/miodroid"
                prefix = user_prefix if rootless else ""
                _, state = machine.execute(prefix + "lxc-info -P " + work + "/lxc -n miodroid -sH")
                if attempt > 5 and "STOPPED" in state:
                    raise Exception("Android container stopped before completing boot")
                time.sleep(2)
            raise Exception("Android did not complete boot within 300 seconds")
        def diagnostics():
            work = "/home/alice/.local/share/miodroid" if rootless else "/var/lib/miodroid"
            commands = [
                "journalctl -b --no-pager -n 200",
                "cat " + work + "/miodroid.log " + work + "/lxc.log 2>/dev/null | tail -300",
                "cat " + work + "/lxc/miodroid/rootfs/data/miodroid-rootless-init.log 2>/dev/null",
                user("printf '%s\\n' \"$PATH\"; command -v newuidmap; ls -l /run/wrappers/bin/newuidmap /run/wrappers/bin/newgidmap"),
                "cat /tmp/miodroid-session.log /tmp/weston.log /tmp/pulse.log 2>/dev/null | tail -150",
                user("cat /tmp/miodroid-notifications.log 2>/dev/null; systemctl --user status miodroid-test-notification-receiver.service --no-pager; busctl --user list | grep -E 'Notifications|miodroid'"),
                android("dumpsys activity activities; dumpsys window displays; dumpsys audio"),
                android("settings get secure enabled_notification_listeners; dumpsys notification --noredact | grep -i -C 4 -E 'waydroid|miodroid|miodroid-vm|listener' | tail -200"),
                android("logcat -d -b crash; logcat -d -t 250"),
            ]
            for command in commands:
                try:
                    status, output = machine.execute(command)
                    print(f"Diagnostic (status {status}): {command}\n{output}")
                except Exception as diagnostic_error:
                    # A broken VM connection or output encoder should not hide
                    # the original assertion/command failure.
                    print(f"Diagnostic failed: {command}\n{diagnostic_error}")

        try:
            with subtest("real desktop services"):
                machine.succeed(user("weston --backend=headless --renderer=pixman --socket=wayland-0 --idle-time=0 > /tmp/weston.log 2>&1 &"))
                machine.succeed(user("pulseaudio --daemonize=no -n --exit-idle-time=-1 --load='module-native-protocol-unix auth-anonymous=1 socket=/run/user/1000/pulse/native' --load='module-null-sink sink_name=test' > /tmp/pulse.log 2>&1 &"))
                machine.wait_until_succeeds(user("test -S /run/user/1000/wayland-0 && pactl info"), timeout=30)
                machine.succeed(user("chmod 0600 /run/user/1000/wayland-0 /run/user/1000/pulse/native"))
                machine.succeed(user("systemctl --user start miodroid-test-notification-receiver.service"))
                machine.wait_until_succeeds(user("busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications GetCapabilities"), timeout=30)
                socket_modes = machine.succeed(user("stat -c '%a' /run/user/1000/wayland-0 /run/user/1000/pulse/native"))
                machine.succeed(user("test $(stat -c %a /run/user/1000) = 700"))

            with subtest("initialize from pinned images"):
                prefix = user_prefix if rootless else ""
                machine.succeed(prefix + "miodroid --details-to-stdout init", timeout=300)
                work = "/home/alice/.local/share/miodroid" if rootless else "/var/lib/miodroid"
                # WayDroid's notification relay is opt-in at Android service
                # construction time. The host turns this base property into
                # vendor/waydroid.prop when the session starts.
                machine.succeed((user_prefix if rootless else "") + "printf '%s\\n' 'persist.waydroid.forward_notifications=true' >> " + work + "/miodroid_base.prop")
                if rootless:
                    machine.succeed(user("systemctl --user start miodroid-test-container.service"))
                else:
                    machine.wait_for_unit("miodroid-container.service")

            with subtest("Android boot and host integration"):
                machine.succeed(user("miodroid --details-to-stdout session start > /tmp/miodroid-session.log 2>&1 &"))
                wait_for_android()
                machine.succeed(android("test -c /dev/binder && test -c /dev/vndbinder && test -c /dev/hwbinder"))
                machine.wait_until_succeeds(user("miodroid app list | grep com.android.settings"), timeout=120)
                machine.succeed(android("settings put global device_provisioned 1; settings put secure user_setup_complete 1; settings put system screen_off_timeout 2147483647; input keyevent KEYCODE_WAKEUP; wm dismiss-keyguard"))
                machine.succeed(user("miodroid show-full-ui"))
                machine.succeed(user("miodroid app launch com.android.settings"))
                machine.wait_until_succeeds(android("dumpsys activity activities | grep -E 'mResumedActivity.*[Ss]ettings|topResumedActivity.*[Ss]ettings'"), timeout=60)
                machine.succeed(android("dumpsys SurfaceFlinger | grep -i GLES"))
                for service in ("waydroidhardware", "waydroidusermonitor", "waydroidclipboard", "waydroidnotifications"):
                    machine.wait_until_succeeds(android("service check " + service + " | grep ': found$'"), timeout=60)
                machine.wait_until_succeeds(user("pactl list short clients | grep -i -E 'protocol-native|waydroid|miodroid'"), timeout=60)
                assert machine.succeed(user("stat -c '%a' /run/user/1000/wayland-0 /run/user/1000/pulse/native")) == socket_modes
                machine.succeed(user("test $(stat -c %a /run/user/1000) = 700"))
                if rootless:
                    # A rootless launch must not chmod host devices or require
                    # global Binder nodes. Its Binder mount is per manager.
                    machine.succeed("test ! -e /dev/binder")
                    machine.succeed(android("test $(id -u) = 0"))
                    machine.succeed(user("grep -q '2147483647' $MIODROID_WORK/lxc/miodroid/config"))

            with subtest("desktop notification delivery"):
                machine.succeed(android("cmd notification post -t 'Miodroid VM' miodroid-vm miodroid-vm-notification", uid=2000))
                machine.wait_until_succeeds("grep -q miodroid-vm-notification /tmp/miodroid-notifications.jsonl", timeout=30)

            with subtest("network and persistent userdata"):
                machine.succeed(android("ip -4 addr show eth0 | grep 'inet '"))
                machine.succeed("python3 -m http.server 8080 --directory /etc > /tmp/miodroid-http.log 2>&1 &")
                bridge = "lxcbr0" if rootless else "miodroid0"
                address = machine.succeed("ip -4 -o addr show dev " + bridge).split()[3].split('/')[0]
                machine.wait_until_succeeds(android("printf 'GET /hostname HTTP/1.0\\r\\n\\r\\n' | toybox nc -w 5 " + address + " 8080 | grep machine"), timeout=30)
                if rootless:
                    machine.succeed(user("grep -q 'lxc.idmap = u 1 100000 2097151' $MIODROID_WORK/lxc/miodroid/config"))
                    machine.succeed(user("grep -q 'lxc.idmap = u 2147483647 2197151 1' $MIODROID_WORK/lxc/miodroid/config"))
                machine.succeed(android("echo miodroid-persistent > /data/local/tmp/miodroid-test"))
                machine.succeed(user("miodroid prop set persist.miodroid.test working"))
                machine.succeed(user("miodroid prop get persist.miodroid.test | grep working"))

            with subtest("freeze, restart and stop"):
                if rootless:
                    # User delegated cgroups do not expose cgroup.freeze to an
                    # unprivileged LXC manager; exercise the supported lifecycle
                    # operations without claiming freeze support.
                    machine.succeed(user("miodroid --details-to-stdout container restart"))
                else:
                    # Restart also refreshes the desktop session services, so
                    # keep root privileges while pointing D-Bus at alice's bus.
                    machine.succeed("env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus miodroid --details-to-stdout container freeze")
                    machine.succeed("env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus miodroid --details-to-stdout container unfreeze")
                    machine.succeed("env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus miodroid --details-to-stdout container restart")
                wait_for_android()
                machine.succeed(android("grep miodroid-persistent /data/local/tmp/miodroid-test"))
                if rootless:
                    machine.succeed(user("miodroid session stop"))
                else:
                    machine.succeed("env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus miodroid session stop")
                work = "/home/alice/.local/share/miodroid" if rootless else "/var/lib/miodroid"
                machine.wait_until_succeeds((user_prefix if rootless else "") + "lxc-info -P " + work + "/lxc -n miodroid -sH | grep STOPPED")
        except Exception:
            diagnostics()
            raise
      '';
    };
in
{
  desktop-sockets = runCommand "miodroid-desktop-sockets" { } ''
    ${pkgs.python3}/bin/python3 ${./tests/socket-proxy.py} ${package}/lib/miodroid/tools/helpers/socket_proxy.py
    touch $out
  '';
  rootful = mkTest { rootless = false; };
  rootless = mkTest { rootless = true; };
  rootless-grow = mkTest {
    rootless = true;
    strategy = "grow";
  };
}
