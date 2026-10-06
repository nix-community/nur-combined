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
      environment.systemPackages = [ pkgs.python3 ];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("zgrep -q 'ANDROID_BINDER_IPC=y' /proc/config.gz || test -e /sys/module/binder_linux")
      machine.succeed("mkdir -p /dev/binderfs && mount -t binder binder /dev/binderfs")
      machine.succeed("test -e /dev/binderfs/binder -a -e /dev/binderfs/vndbinder -a -e /dev/binderfs/hwbinder")
      machine.wait_for_unit("miodroid-container.service")
      machine.succeed("python3 -m http.server 8000 --directory /etc/miodroid-test >/tmp/miodroid-http.log 2>&1 &")
      machine.succeed("miodroid init -c http://127.0.0.1:8000/system -v http://127.0.0.1:8000/vendor -r lineage -s VANILLA", timeout=3600)
      machine.succeed("""cat > /tmp/miodroid-session-test.sh << 'EOF'
      #!/bin/sh
      set -eu
      install -d -m 0700 /run/user/0
      mkdir -p /run/user/0/pulse
      # Listening Wayland and PulseAudio sockets for the session to bind into
      # the container.
      python3 << 'PYEOF' &
      import os, socket, time
      for path in ["/run/user/0/wayland-0", "/run/user/0/pulse/native"]:
          if os.path.exists(path):
              os.unlink(path)
          s = socket.socket(socket.AF_UNIX)
          s.bind(path)
          s.listen(1)
      time.sleep(600)
      PYEOF
      wlserver=$!

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
                  kill $session $wlserver 2>/dev/null || true
                  exit 0
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

      echo "=== SESSION LOG ===" ; cat /tmp/miodroid-session.log || true
      echo "=== MIODROID LOG ===" ; cat /var/lib/miodroid/miodroid.log 2>/dev/null || true
      echo "=== JOURNALCTL ===" ; journalctl --user -n 100 -xe || true
      kill $session $wlserver 2>/dev/null || true
      exit 1
      EOF
      chmod 0755 /tmp/miodroid-session-test.sh""")
      machine.succeed("dbus-run-session -- /tmp/miodroid-session-test.sh", timeout=300)
      machine.wait_for_unit("miodroid-container.service")
      machine.succeed("test -f /var/lib/miodroid/images/system.img")
      machine.succeed("test -f /var/lib/miodroid/images/vendor.img")
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
      };

      virtualisation.memorySize = 4096;
      virtualisation.diskSize = 8192;
      boot.kernelPackages = binderKernel;
      boot.extraModprobeConfig = "options binder_linux devices=binder,vndbinder,hwbinder";
      environment.etc."miodroid-test".source = testFiles;
      environment.systemPackages = [ pkgs.python3 ];

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
      machine.wait_for_unit("miodroid-rootless-helper.service")
      machine.succeed("zgrep -q 'ANDROID_BINDER_IPC=y' /proc/config.gz || test -e /sys/module/binder_linux")
      # miodroid-rootless-helper already mounts binderfs and hands the nodes
      # over to the miodroid group; mounting a second binderfs here would hide
      # that instance (and its permissions) behind a fresh, root-only one.
      machine.succeed("mountpoint -q /dev/binderfs || { mkdir -p /dev/binderfs && mount -t binder binder /dev/binderfs; }")
      machine.succeed("test -e /dev/binderfs/binder -a -e /dev/binderfs/vndbinder -a -e /dev/binderfs/hwbinder")
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
      if test ! -f "$MIODROID_WORK/images/system.img"; then
          cat "$MIODROID_WORK/miodroid.cfg"
          cat "$MIODROID_WORK/miodroid.log"
          find "$MIODROID_WORK" -maxdepth 3 -type f -print
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
      machine.succeed("su - alice -c 'test -r /dev/binder -a -w /dev/binder'")
      machine.succeed("""cat > /tmp/test-session.sh << 'EOFSCRIPT'
      #!/bin/sh
      set -eu
      export MIODROID_ROOTLESS=1
      export MIODROID_WORK=/home/alice/.local/share/miodroid
      export XDG_RUNTIME_DIR=/run/user/1000
      export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

      mkdir -p /run/user/1000/pulse
      # Listening Wayland and PulseAudio sockets for the session to bind into
      # the container.
      python3 << 'PYEOF' &
      import os, socket, time
      for path in ["/run/user/1000/wayland-0", "/run/user/1000/pulse/native"]:
          if os.path.exists(path):
              os.unlink(path)
          s = socket.socket(socket.AF_UNIX)
          s.bind(path)
          s.listen(1)
      time.sleep(600)
      PYEOF
      wlserver=$!

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
                  kill $session $wlserver 2>/dev/null || true
                  exit 0
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

      echo "=== SESSION LOG ===" ; cat /tmp/miodroid-session.log || true
      echo "=== MIODROID LOG ===" ; cat /home/alice/.local/share/miodroid/miodroid.log 2>/dev/null || true
      echo "=== KMSG (container init) ===" ; dmesg | tail -n 80 || true
      echo "=== JOURNALCTL ===" ; journalctl --user -n 100 -xe || true
      kill $session $wlserver 2>/dev/null || true
      exit 1
      EOFSCRIPT
      chmod 0755 /tmp/test-session.sh""")
      machine.succeed("su - alice -c '/tmp/test-session.sh'", timeout=300)
    '';
  };
}
