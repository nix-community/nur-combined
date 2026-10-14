{
  package,
  fetchurl,
  pkgs,
  runCommand,
  testers,
}:

let
  systemImage = fetchurl {
    url = "https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_x86_64/lineage-20.0-20260927-VANILLA-waydroid_x86_64-system.zip/download";
    hash = "sha256-BTVSclv0riXi0/fm8ZRyAylKqdc9wX/h86vmRuXTvYo=";
  };
  vendorImage = fetchurl {
    url = "https://sourceforge.net/projects/waydroid/files/images/vendor/waydroid_x86_64/lineage-20.0-20260927-MAINLINE-waydroid_x86_64-vendor.zip/download";
    hash = "sha256-2RG4NT9sgHuUeQscQcZ+hjqfPc0c8+wCMjUTmCNa/Xo=";
  };
  testFiles = runCommand "miodroid-rootful-test-files" { } ''
    mkdir -p $out/system/lineage/waydroid_x86_64
    mkdir -p $out/vendor/waydroid_x86_64
    cp ${systemImage} $out/system.zip
    cp ${vendorImage} $out/vendor.zip
    cat > $out/system/lineage/waydroid_x86_64/VANILLA.json <<EOF
    {"response":[{"datetime":1790539062,"filename":"system.zip","id":"053552725bf4ae25e2d3f7e6f1947203294aa9d73dc17fe1f3abe646e5d3bd8a","url":"http://127.0.0.1:8000/system.zip"}]}
    EOF
    cat > $out/vendor/waydroid_x86_64/MAINLINE.json <<EOF
    {"response":[{"datetime":1790542319,"filename":"vendor.zip","id":"d911b8353f6c807b94790b1c41c67e863a9f3dcd1cf3ec0232351398235afd7a","url":"http://127.0.0.1:8000/vendor.zip"}]}
    EOF
  '';
in
let
  binderKernel = pkgs.linuxPackagesFor (
    pkgs.linux_latest.override {
      structuredExtraConfig = with pkgs.lib.kernel; {
        ANDROID_BINDER_IPC = yes;
        ANDROID_BINDERFS = yes;
        MEMFD_CREATE = yes;
        BRIDGE = yes;
        BRIDGE_NETFILTER = yes;
        NETFILTER = yes;
        NETFILTER_ADVANCED = yes;
        NETFILTER_XTABLES = yes;
        NF_CONNTRACK = yes;
        NF_NAT = yes;
        IP_NF_IPTABLES = yes;
        NETFILTER_XT_TARGET_MASQUERADE = yes;
        NETFILTER_XT_MATCH_COMMENT = yes;
        NETFILTER_XT_MATCH_CONNTRACK = yes;
        NETFILTER_XT_MATCH_ADDRTYPE = yes;
        NF_TABLES = yes;
        NF_TABLES_INET = yes;
        NFT_CT = yes;
        NFT_MASQ = yes;
        NFT_REDIR = yes;
        NFT_NAT = yes;
        NFT_FIB = module;
        NFT_REJECT = yes;
        NFT_COMPAT = yes;
        FUSE_FS = yes;
        USER_NS = yes;
      };
    }
  );
in
{
  rootful = testers.runNixOSTest {
    name = "miodroid-rootful";

    nodes.machine = {
      imports = [ ../../../modules/miodroid.nix ];

      virtualisation.miodroid = {
        enable = true;
        package = package;
      };

      virtualisation.memorySize = 4096;
      virtualisation.diskSize = 8192;
      boot.kernelPackages = binderKernel;
      boot.extraModprobeConfig = "options binder_linux devices=binder,vndbinder,hwbinder";
      environment.etc."miodroid-test".source = testFiles;
      environment.systemPackages = [
        pkgs.python3
        pkgs.weston
      ];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("zgrep -q 'ANDROID_BINDER_IPC=y' /proc/config.gz || test -e /sys/module/binder_linux")
      machine.succeed("mkdir -p /dev/binderfs && mount -t binder binder /dev/binderfs")
      machine.succeed("test -e /dev/binderfs/binder -a -e /dev/binderfs/vndbinder -a -e /dev/binderfs/hwbinder")
      machine.wait_for_unit("miodroid-container.service")
      machine.succeed("python3 -m http.server 8000 --directory /etc/miodroid-test >/tmp/miodroid-http.log 2>&1 &")
      machine.succeed("miodroid init -c http://127.0.0.1:8000/system -v http://127.0.0.1:8000/vendor -r lineage -s VANILLA", timeout=3600)
      machine.succeed("miodroid prop set ro.hardware.gralloc default")
      machine.succeed("miodroid prop set ro.hardware.egl swiftshader")
      machine.succeed("""cat > /tmp/miodroid-session-test.sh << 'EOF'
      #!/bin/sh
      set -eu
      install -d -m 0700 /run/user/0
      mkdir -p /run/user/0/pulse
      # Start a real Wayland compositor for Waydroid to connect to,
      # and a fake PulseAudio socket.
      XDG_RUNTIME_DIR=/run/user/0 weston --backend=headless-backend.so --socket=wayland-0 --idle-time=0 >/tmp/weston.log 2>&1 &
      wlserver=$!
      python3 << 'PYEOF' &
      import os, socket, time
      for path in ["/run/user/0/pulse/native"]:
          if os.path.exists(path):
              os.unlink(path)
          s = socket.socket(socket.AF_UNIX)
          s.bind(path)
          s.listen(1)
      time.sleep(600)
      PYEOF
      pulseserver=$!

      # `session start` stays in the foreground for as long as the session
      # lives, so run it in the background and watch the container instead.
      # The container has to stay up, not just reach RUNNING once; the session
      # is left running, the assertions below stop it.
      XDG_RUNTIME_DIR=/run/user/0 miodroid session start > /tmp/miodroid-session.log 2>&1 &
      session=$!

      running=0
      for i in $(seq 1 180); do
          if lxc-info -P /var/lib/miodroid/lxc -n miodroid -sH | grep -q RUNNING; then
              running=$((running + 1))
              if test $running -ge 10; then
                  echo container-running
                  break
              fi
          else
              running=0
          fi
          if ! test -d /proc/$session; then
              echo "session exited before the container came up"
              break
          fi
          sleep 1
      done

      # RUNNING only means that Android's init started. A container that never
      # reaches sys.boot_completed=1 is not a working Miodroid, so gate the
      # test on Android's own boot flag instead of on the LXC state.
      if test $running -ge 10; then
          for i in $(seq 1 900); do
              if lxc-attach -P /var/lib/miodroid/lxc -n miodroid -- \
                      /system/bin/getprop sys.boot_completed 2>/dev/null |
                      grep -q '^1'; then
                  echo android-booted
                  kill -9 $session $wlserver 2>/dev/null || true
                  exit 0
              fi
              if ! test -d /proc/$session; then
                  echo "session exited while Android was booting"
                  break
              fi
              sleep 1
          done
          echo "Android never reported sys.boot_completed=1"
      fi

      echo "=== SESSION LOG ===" ; cat /tmp/miodroid-session.log || true
      echo "=== LOGCAT ===" ; lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- /system/bin/logcat -d || true
      echo "=== MIODROID LOG ===" ; cat /var/lib/miodroid/miodroid.log 2>/dev/null || true
      echo "=== JOURNALCTL ===" ; journalctl --user -n 100 -xe || true
      kill -9 $session $wlserver 2>/dev/null || true
      exit 1
      EOF
      chmod 0755 /tmp/miodroid-session-test.sh""")
      machine.succeed("dbus-run-session -- /tmp/miodroid-session-test.sh", timeout=1200)
      machine.wait_for_unit("miodroid-container.service")
      # A pre-installed imagePackage lands in /etc/miodroid-extra/images, and
      # init records wherever it took them from as images_path -- so resolve
      # that instead of assuming the OTA download location.
      images_path = machine.succeed(
          "sed -n 's/^images_path = //p' /var/lib/miodroid/miodroid.cfg"
      ).strip()
      assert images_path, "miodroid.cfg has no images_path"
      machine.succeed(f"test -f {images_path}/system.img")
      machine.succeed(f"test -f {images_path}/vendor.img")
      machine.succeed("test -f /var/lib/miodroid/lxc/miodroid/config")
      machine.succeed("test -f /var/lib/miodroid/lxc/miodroid/miodroid.seccomp")
    '';
  };

  rootless = testers.runNixOSTest {
    name = "miodroid-rootless";

    nodes.machine = {
      imports = [ ../../../modules/miodroid.nix ];

      virtualisation.miodroid-rootless = {
        enable = true;
        package = package;
        # imagePackage is left at its default: the Robotnix waydroid_x86_64
        # build this repo produces, which is the image the rootless path is
        # meant to run.
      };

      virtualisation.memorySize = 4096;
      # The rootless "grow" strategy copies each image into the work directory
      # and adds 1 GiB to the copy, on top of the downloaded images themselves,
      # so the default 8 GiB is not enough for a real Android image pair.
      virtualisation.diskSize = 16384;
      boot.kernelPackages = binderKernel;
      boot.extraModprobeConfig = "options binder_linux devices=binder,vndbinder,hwbinder";
      environment.etc."miodroid-test".source = testFiles;
      environment.systemPackages = [
        pkgs.python3
        pkgs.weston
      ];

      users.users.alice = {
        isNormalUser = true;
        extraGroups = [
          "miodroid"
          "lxc-user"
          "fuse"
        ];
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };

      programs.fuse.enable = true;
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("zgrep -q 'ANDROID_BINDER_IPC=y' /proc/config.gz || test -e /sys/module/binder_linux")
      # Android's init logs to /dev/kmsg and the rootless container is given the
      # host's node (mknod is refused inside a user namespace), so let the
      # container's root write there.
      machine.succeed("chmod 0666 /dev/kmsg")
      machine.succeed("python3 -m http.server 8000 --directory /etc/miodroid-test >/tmp/miodroid-http.log 2>&1 &")
      machine.succeed("sleep 2")
      machine.succeed("loginctl enable-linger alice")
      machine.wait_until_succeeds("test -S /run/user/1000/bus")
      machine.wait_until_succeeds("su - alice -c 'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus busctl --user call org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.DBus.Peer Ping'")
      machine.succeed("install -d -m 0700 -o alice -g users /run/user/1000")
      machine.succeed("""cat > /tmp/miodroid-rootless-test.sh <<'EOF'
      #!/bin/sh
      set -eu
      if ! miodroid init -c http://127.0.0.1:8000/system \
          -v http://127.0.0.1:8000/vendor -r lineage -s VANILLA; then
          if test -f /tmp/tools.log; then cat /tmp/tools.log; fi
          exit 1
      fi
      miodroid prop set ro.hardware.gralloc default
      miodroid prop set ro.hardware.egl swiftshader
      # The module pre-installs our Robotnix system.img/vendor.img in
      # /etc/miodroid-extra/images, which init records as images_path instead
      # of downloading an OTA into <work>/images. Assert the directory init
      # settled on really holds both images rather than the work directory.
      images_path=$(sed -n 's/^images_path = //p' "$MIODROID_WORK/miodroid.cfg")
      if test ! -f "$images_path/system.img" ||
          test ! -f "$images_path/vendor.img"; then
          echo "init did not resolve usable images (images_path=$images_path)"
          cat "$MIODROID_WORK/miodroid.cfg" || true
          cat "$MIODROID_WORK/miodroid.log" || true
          find "$MIODROID_WORK" -maxdepth 3 -type f -print || true
          exit 1
      fi
      echo rootless-init-complete
      EOF
      chmod 0755 /tmp/miodroid-rootless-test.sh
      """)
      machine.succeed(
          "su - alice -c 'env MIODROID_ROOTLESS=1 "
          "MIODROID_WORK=/home/alice/.local/share/miodroid "
          "XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
          "/tmp/miodroid-rootless-test.sh'",
          timeout=420,
      )
      machine.succeed("test -f /home/alice/.local/share/miodroid/miodroid.cfg")
      # The unprivileged network and the container's idmap are what make the
      # rootless container reachable and able to run Android; assert them
      # instead of only printing them while debugging.
      machine.succeed("grep -q 'lxcbr0' /etc/lxc/lxc-usernet")
      machine.succeed("grep -q 'lxc.idmap = u 0 1000 1' /home/alice/.local/share/miodroid/lxc/miodroid/config")
      machine.succeed("grep -q 'lxc.rootfs.mount' /home/alice/.local/share/miodroid/lxc/miodroid/config")
      # The container is told to bring up its own binderfs.
      machine.succeed("grep -q 'zz-miodroid-binder.rc' /home/alice/.local/share/miodroid/lxc/miodroid/config_nodes")
      machine.succeed("""cat > /tmp/test-session.sh << 'EOFSCRIPT'
      #!/bin/sh
      set -eu
      export MIODROID_ROOTLESS=1
      export MIODROID_WORK=/home/alice/.local/share/miodroid
      export XDG_RUNTIME_DIR=/run/user/1000
      export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

      mkdir -p /run/user/1000/pulse
      # Start a real Wayland compositor for Waydroid to connect to,
      # and a fake PulseAudio socket.
      XDG_RUNTIME_DIR=/run/user/1000 weston --backend=headless-backend.so --socket=wayland-0 --idle-time=0 >/tmp/weston.log 2>&1 &
      wlserver=$!
      # The listener has to outlive the session start, so it stays in the
      # background: keep its output out of the test driver's pipe as well,
      # otherwise the driver waits for this process instead of the script when
      # the script fails early.
      python3 << 'PYEOF' > /tmp/miodroid-pulse.log 2>&1 &
      import os, socket, time
      for path in ["/run/user/1000/pulse/native"]:
          if os.path.exists(path):
              os.unlink(path)
          s = socket.socket(socket.AF_UNIX)
          s.bind(path)
          s.listen(1)
      time.sleep(600)
      PYEOF
      pulseserver=$!

      # `session start` stays in the foreground for as long as the session
      # lives, so run it in the background and watch the container instead.
      # The container has to stay up, not just reach RUNNING once.
      miodroid --details-to-stdout session start > /tmp/miodroid-session.log 2>&1 &
      session=$!

      running=0
      for i in $(seq 1 180); do
          if lxc-info -P /home/alice/.local/share/miodroid/lxc -n miodroid -sH | grep -q RUNNING; then
              running=$((running + 1))
              if test $running -ge 10; then
                  echo container-running
                  break
              fi
          else
              running=0
          fi
          if ! test -d /proc/$session; then
              echo "session exited before the container came up"
              break
          fi
          sleep 1
      done

      # RUNNING only means that Android's init started; the interesting part of
      # rootless mode is whether Android itself boots with its own binderfs,
      # its idmapped root and the user's images.
      if test $running -ge 10; then
          # 420 iterations, not 900: each iteration costs an lxc-attach on top of
          # the sleep, so 900 runs past this step's 1200s timeout and the failure
          # diagnostics below never get to print.  The rootful test reaches
          # boot_completed in ~65s, so this is still generous.
          for i in $(seq 1 420); do
              if lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- \
                      /system/bin/getprop sys.boot_completed 2>/dev/null |
                      grep -q '^1'; then
                  echo android-booted
                  # boot_completed=1 already implies that Android's
                  # servicemanager opened /dev/binder, so this only makes the
                  # reason for a failure obvious: the container must have
                  # mounted its own binderfs, with no host device nodes.
                  if ! lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- \
                          /system/bin/ls -L /dev/binder /dev/vndbinder /dev/hwbinder; then
                      echo "container is missing its binder devices"
                      kill -9 $session $wlserver $pulseserver 2>/dev/null || true
                      exit 1
                  fi
                  kill -9 $session $wlserver $pulseserver 2>/dev/null || true
                  exit 0
              fi
              if ! test -d /proc/$session; then
                  echo "session exited while Android was booting"
                  break
              fi
              # Probe early and repeatedly, while the container is still up:
              # once init's fatal-reboot abort kills PID 1, LXC tears the
              # container down and lxc-attach fails with "Failed to get init
              # pid".  At i=90 it was already gone.  dmesg is unreadable as
              # this user (dmesg_restrict), so the container's own logcat is
              # what carries a crashing service's message.
              case "$i" in 20|45|90)
                  echo "=== MIDBOOT DIAGNOSTICS at i=$i ==="
                  lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- \
                      /system/bin/ls -lL /dev/binder /dev/vndbinder /dev/hwbinder /dev/binderfs 2>&1 | head -14 || true
                  lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- \
                      /system/bin/logcat -d -v brief 2>&1 | grep -iE "abort|fatal|binder|zygote|servicemanager|apex" | tail -40 || true
                  lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- \
                      /system/bin/logcat -d -b crash -v brief 2>&1 | tail -30 || true
                  coredumpctl --no-pager --no-legend list 2>&1 | tail -8 || true
                  ;;
              esac
              sleep 1
          done
          echo "Android never reported sys.boot_completed=1"
      fi

      echo "=== SESSION LOG ===" ; cat /tmp/miodroid-session.log || true
      echo "=== LOGCAT ===" ; lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- /system/bin/logcat -d | tail -n 300 || true
      echo "=== KMSG (container init) ===" ; dmesg | tail -n 80 || true
      echo "=== JOURNALCTL ===" ; journalctl --user -n 100 -xe || true
      # The container's own Android crashes surface through the VM's
      # systemd-coredump (the container shares the PID namespace), so this is
      # where an aborting service's message and backtrace are.
      echo "=== CORE BACKTRACE (last abort) ===" ; coredumpctl --no-pager info 2>&1 | head -70 || true
      echo "=== CONTAINER BINDER STATE ===" ; lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- /system/bin/ls -lL /dev/binder /dev/vndbinder /dev/hwbinder /dev/binderfs 2>&1 | head -20 || true
      echo "=== CONTAINER LOG, filtered ===" ; lxc-attach -P /home/alice/.local/share/miodroid/lxc -n miodroid -- /system/bin/logcat -d -v brief 2>&1 | grep -iE "abort|fatal|binder|zygote|servicemanager|apex" | tail -60 || true
      kill -9 $session $wlserver $pulseserver 2>/dev/null || true
      # Reaching this point means Android never reported boot_completed, so the
      # container is not a working Miodroid; fail with that reason.  (These
      # diagnostics only reach the test log through the VM console: read the
      # full log with `nix log <vm-test-run drv>` and search for "init:".)
      echo "Failed to boot rootless container!"
      exit 1
      EOFSCRIPT
      chmod 0755 /tmp/test-session.sh""")
      status, _ = machine.execute("su - alice -c '/tmp/test-session.sh'", timeout=1200)
      # Root-side, post-mortem evidence.  Android's init logs to the shared
      # kernel log, so a crashing service's LOG(FATAL) message is here even
      # though the container has exited -- and lxc-attach cannot be used in
      # rootless mode at all (cgroup_attach_create_leaf: Permission denied, so
      # even "Failed to attach to container"), which is also why the in-script
      # getprop boot check above can never succeed.
      machine.succeed(
          "(journalctl -k --no-pager || dmesg) | "
          "grep -iE 'init: |binder|servicemanager|abort|fatal|zygote|denied' | tail -120 || true"
      )
      machine.succeed("coredumpctl --no-pager --no-legend list || true")
      assert status == 0, "miodroid rootless session failed (kernel log above)"
    '';
  };
}
