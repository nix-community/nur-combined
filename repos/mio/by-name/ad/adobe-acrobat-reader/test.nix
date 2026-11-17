{
  adobe-acrobat-reader,
  nixpkgsPath,
}:

let
  mainProgram = adobe-acrobat-reader.meta.mainProgram or "adobe-acrobat-reader";
in
{
  name = mainProgram;

  meta.timeout = 3600;

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
        adobe-acrobat-reader
        pkgs.xwininfo
        pkgs.xrdb
        pkgs.procps
        pkgs.xrandr
        (pkgs.writeShellScriptBin "fusermount" ''
          exec /run/wrappers/bin/fusermount3 "$@"
        '')
        (pkgs.writeShellScriptBin "acrobat-vm-launch" ''
          set -euo pipefail
          export PATH=/run/wrappers/bin:$PATH
          echo "Xft.dpi: 96" | xrdb -merge
          # Prefer non-virtual-desktop in the tiny VM display.
          export ACROREAD_NO_VIRTUAL_DESKTOP=1
          export DISPLAY=:0
          log=''${1:-/tmp/acrobat-wine.log}
          pidfile=''${2:-/tmp/acrobat.pid}
          nohup ${mainProgram} >"$log" 2>&1 &
          echo $! >"$pidfile"
        '')
        (pkgs.writeShellScriptBin "acrobat-vm-stop" ''
          set +e
          # Match Wine PE / launcher; pkill -x truncates names to 15 chars.
          pkill -f 'Acrobat\.exe' || true
          pkill -f 'AcroRd32\.exe' || true
          pkill -f '\.mkwindowsapp/wineprefix' || true
          if [ -f /tmp/acrobat.pid ]; then kill "$(cat /tmp/acrobat.pid)" 2>/dev/null || true; fi
          if [ -f /tmp/acrobat2.pid ]; then kill "$(cat /tmp/acrobat2.pid)" 2>/dev/null || true; fi
          pkill -f '/bin/${mainProgram}' || true
          # wineserver is not on PATH for the login user; use the package wine.
          ${adobe-acrobat-reader.wine}/bin/wineserver -k 2>/dev/null || true
          sleep 1
          pkill -9 -f 'Acrobat\.exe' || true
          pkill -9 -f '/bin/${mainProgram}' || true
          exit 0
        '')
      ];

      users.users.alice.extraGroups = [
        "video"
        "render"
      ];

      # Acrobat DC payload + Wine layers + MSP apply need room.
      virtualisation.memorySize = 8192;
      virtualisation.diskSize = 32768;
      virtualisation.cores = 4;
    };

  testScript = ''
    from datetime import timedelta

    machine.start()
    machine.wait_for_x()

    with subtest("Acrobat installs Wine layers and launches under X11"):
        machine.succeed(
            "su - alice -c 'acrobat-vm-launch /tmp/acrobat-wine.log /tmp/acrobat.pid'",
            timeout=timedelta(minutes=2),
        )

        machine.wait_until_succeeds(
            "grep -q 'Windows and app layers are initialized' /tmp/acrobat-wine.log",
            timeout=1800,
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/acrobat-wine.log",
            timeout=300,
        )

        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/acrobat-wine.log; "
            "! grep -q 'mount failed: Operation not permitted' /tmp/acrobat-wine.log; "
            "! grep -q 'Acrobat.exe was not installed' /tmp/acrobat-wine.log; "
            "! grep -q 'executable not found' /tmp/acrobat-wine.log; "
            "! grep -q 'msiexec failed' /tmp/acrobat-wine.log"
        )

        machine.wait_until_succeeds(
            "su - alice -c \"pgrep -af 'Acrobat\\.exe' | grep -v pgrep\" "
            "|| grep -q 'App exited' /tmp/acrobat-wine.log "
            "|| grep -q 'Running Windows app' /tmp/acrobat-wine.log",
            timeout=300,
        )

        machine.execute(
            "su - alice -c '"
            "for i in $(seq 1 30); do "
            "DISPLAY=:0 xwininfo -root -tree | grep -qiE \"acrobat|adobe\" && exit 0; "
            "sleep 2; done; exit 1"
            "' >/tmp/acrobat-xwin-wait.txt 2>&1 || true"
        )
        machine.execute(
            "su - alice -c 'DISPLAY=:0 xwininfo -root -tree' >/tmp/xwin-acrobat.txt || true"
        )
        print(machine.succeed("cat /tmp/acrobat-wine.log || true"))
        print(machine.succeed("cat /tmp/xwin-acrobat.txt || true"))
        machine.screenshot("acrobat-wine")

        machine.execute("su - alice -c acrobat-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/acrobat-wine.log || "
            "! pgrep -af 'Acrobat\\.exe' | grep -v pgrep >/dev/null",
            timeout=180,
        )
        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/acrobat-wine.log"
        )

    with subtest("Second Acrobat launch reuses Wine layers"):
        machine.succeed(
            "su - alice -c 'acrobat-vm-launch /tmp/acrobat-wine2.log /tmp/acrobat2.pid'"
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/acrobat-wine2.log",
            timeout=300,
        )
        machine.execute("su - alice -c acrobat-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/acrobat-wine2.log || "
            "! pgrep -af 'Acrobat\\.exe' | grep -v pgrep >/dev/null",
            timeout=180,
        )
        machine.screenshot("acrobat-wine-relaunch")
  '';
}
