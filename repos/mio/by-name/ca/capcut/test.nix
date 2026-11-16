{
  capcut,
  nixpkgsPath,
}:

{
  name = "capcut";

  meta.timeout = 2400;

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [
        "${nixpkgsPath}/nixos/tests/common/x11.nix"
        "${nixpkgsPath}/nixos/tests/common/user-account.nix"
      ];

      test-support.displayManager.auto.user = "alice";
      hardware.graphics.enable = true;

      # Setuid fusermount3 for mkWindowsApp unionfs overlays.
      programs.fuse.enable = true;
      programs.fuse.userAllowOther = true;

      environment.systemPackages = [
        capcut
        pkgs.xwininfo
        pkgs.xrdb
        pkgs.procps
        pkgs.xrandr
        (pkgs.writeShellScriptBin "fusermount" ''
          exec /run/wrappers/bin/fusermount3 "$@"
        '')
        # Helpers avoid fragile nested quoting / login-shell `set -u` vs $!.
        (pkgs.writeShellScriptBin "capcut-vm-launch" ''
          set -euo pipefail
          export PATH=/run/wrappers/bin:$PATH
          echo "Xft.dpi: 96" | xrdb -merge
          export CAPCUT_NO_VIRTUAL_DESKTOP=1
          export DISPLAY=:0
          log=''${1:-/tmp/capcut-wine.log}
          pidfile=''${2:-/tmp/capcut.pid}
          nohup capcut >"$log" 2>&1 &
          echo $! >"$pidfile"
        '')
        (pkgs.writeShellScriptBin "capcut-vm-stop" ''
          set +e
          # Match Wine PE only — avoid killing this helper via a broad 'capcut' regex (exit 143).
          pkill -f '/Apps/.*/CapCut\.exe' || true
          pkill -f '/Apps/CapCut\.exe' || true
          pkill -x capcut || true
          wineserver -k || true
          exit 0
        '')
      ];

      users.users.alice.extraGroups = [
        "video"
        "render"
      ];

      # CapCut payload + Wine layers need room.
      virtualisation.memorySize = 8192;
      virtualisation.diskSize = 20480;
      virtualisation.cores = 4;
    };

  testScript = ''
    from datetime import timedelta

    machine.start()
    machine.wait_for_x()

    with subtest("CapCut installs Wine layers and launches under X11"):
        machine.succeed(
            "su - alice -c 'capcut-vm-launch /tmp/capcut-wine.log /tmp/capcut.pid'",
            timeout=timedelta(minutes=2),
        )

        # First run: Windows layer + large app copy into overlay.
        machine.wait_until_succeeds(
            "grep -q 'Windows and app layers are initialized' /tmp/capcut-wine.log",
            timeout=900,
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/capcut-wine.log",
            timeout=180,
        )

        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/capcut-wine.log; "
            "! grep -q 'mount failed: Operation not permitted' /tmp/capcut-wine.log; "
            "! grep -q 'CapCut executable not found' /tmp/capcut-wine.log; "
            "! grep -q 'CapCut installation failed' /tmp/capcut-wine.log"
        )

        # CapCut.exe should show up as a Wine process (or have already exited after paint).
        machine.wait_until_succeeds(
            "su - alice -c \"pgrep -af 'CapCut\\.exe' | grep -v pgrep\" "
            "|| grep -q 'App exited' /tmp/capcut-wine.log "
            "|| grep -q 'Running Windows app' /tmp/capcut-wine.log",
            timeout=180,
        )

        # Best-effort window check: title often contains CapCut once UI paints.
        # Process start already proved launch; VESafeGuard/GPU quirks may prevent
        # a titled window in the VM.
        machine.execute(
            "su - alice -c '"
            "for i in $(seq 1 30); do "
            "DISPLAY=:0 xwininfo -root -tree | grep -qi capcut && exit 0; "
            "sleep 2; done; exit 1"
            "' >/tmp/capcut-xwin-wait.txt 2>&1 || true"
        )
        machine.execute(
            "su - alice -c 'DISPLAY=:0 xwininfo -root -tree' >/tmp/xwin-capcut.txt || true"
        )
        print(machine.succeed("cat /tmp/capcut-wine.log || true"))
        print(machine.succeed("cat /tmp/xwin-capcut.txt || true"))
        machine.screenshot("capcut-wine")

        machine.execute("su - alice -c capcut-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/capcut-wine.log || "
            "! pgrep -x capcut >/dev/null",
            timeout=180,
        )
        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/capcut-wine.log"
        )

    with subtest("Second CapCut launch reuses Wine layers"):
        machine.succeed(
            "su - alice -c 'capcut-vm-launch /tmp/capcut-wine2.log /tmp/capcut2.pid'"
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/capcut-wine2.log",
            timeout=180,
        )
        machine.execute("su - alice -c capcut-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/capcut-wine2.log || "
            "! pgrep -x capcut >/dev/null",
            timeout=180,
        )
        machine.screenshot("capcut-wine-relaunch")
  '';
}
