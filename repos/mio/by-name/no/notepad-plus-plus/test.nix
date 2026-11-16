{
  notepad-plus-plus,
  nixpkgsPath,
}:

{
  name = "notepad-plus-plus";

  meta.timeout = 1800;

  nodes.machine =
    { pkgs, ... }:
    {
      # Import via the caller's nixpkgs path (not `pkgs.path` from the module
      # args) so runNixOSTest does not hit import/config recursion.
      imports = [
        "${nixpkgsPath}/nixos/tests/common/x11.nix"
        "${nixpkgsPath}/nixos/tests/common/user-account.nix"
      ];

      test-support.displayManager.auto.user = "alice";

      # Setuid fusermount3 for mkWindowsApp unionfs overlays.
      programs.fuse.enable = true;
      programs.fuse.userAllowOther = true;

      environment.systemPackages = [
        notepad-plus-plus
        pkgs.xwininfo
        pkgs.xrdb
        pkgs.procps
        (pkgs.writeShellScriptBin "fusermount" ''
          exec /run/wrappers/bin/fusermount3 "$@"
        '')
        # Helpers avoid fragile nested quoting / login-shell `set -u` vs $!.
        (pkgs.writeShellScriptBin "npp-vm-launch" ''
          set -euo pipefail
          export PATH=/run/wrappers/bin:$PATH
          echo "Xft.dpi: 96" | xrdb -merge
          export NOTEPADPP_SKIP_CJKFONTS=1
          export DISPLAY=:0
          log=''${1:-/tmp/npp-wine.log}
          pidfile=''${2:-/tmp/npp.pid}
          shift 2 || true
          nohup notepad-plus-plus "$@" >"$log" 2>&1 &
          echo $! >"$pidfile"
        '')
        (pkgs.writeShellScriptBin "npp-vm-stop" ''
          set +e
          # Match Wine PE / launcher only — avoid killing this helper (exit 143).
          pkill -f '/drive_c/Program Files/Notepad\+\+/notepad\+\+\.exe' || true
          pkill -x notepad-plus-plus || true
          wineserver -k || true
          exit 0
        '')
      ];

      virtualisation.memorySize = 4096;
      virtualisation.diskSize = 10240;
      virtualisation.cores = 2;
    };

  testScript = ''
    from datetime import timedelta

    machine.start()
    machine.wait_for_x()

    with subtest("Wine Notepad++ installs bottle, shows a window, and exits cleanly"):
        # Seed a file to open so we exercise argv forwarding (ARGS array).
        machine.succeed(
            "su - alice -c 'printf hello-from-vm > /home/alice/hello.txt'"
        )

        # Skip winetricks cjkfonts in the VM (slow / network-heavy).
        machine.succeed(
            "su - alice -c 'npp-vm-launch /tmp/npp-wine.log /tmp/npp.pid /home/alice/hello.txt'",
            timeout=timedelta(minutes=2),
        )

        # First run builds Windows + app layers (Wine boot); allow several minutes.
        machine.wait_until_succeeds(
            "grep -q 'Windows and app layers are initialized' /tmp/npp-wine.log",
            timeout=600,
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/npp-wine.log",
            timeout=120,
        )

        # Window title contains Notepad++ once the PE is up.
        machine.wait_until_succeeds(
            "su - alice -c 'DISPLAY=:0 xwininfo -root -tree | grep -qi notepad'",
            timeout=180,
        )

        # Wineboot often prints a harmless ShellExecuteEx during prefix init;
        # only treat post-launch failures as fatal (awk exits 1 on match).
        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/npp-wine.log; "
            "! grep -q 'mount failed: Operation not permitted' /tmp/npp-wine.log; "
            "awk '/Running Windows app/{p=1} p && /Could not translate the specified Unix filename/{exit 1}' /tmp/npp-wine.log; "
            "awk '/Running Windows app/{p=1} p && /ShellExecuteEx failed/{exit 1}' /tmp/npp-wine.log"
        )

        machine.execute(
            "su - alice -c 'DISPLAY=:0 xwininfo -root -tree' >/tmp/xwin-wine.txt || true"
        )
        print(machine.succeed("cat /tmp/xwin-wine.txt || true"))
        print(machine.succeed("cat /tmp/npp-wine.log || true"))
        machine.screenshot("notepad-plus-plus-wine")

        machine.execute("su - alice -c npp-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/npp-wine.log",
            timeout=120,
        )
        machine.succeed(
            "! grep -q 'fusermount: command not found' /tmp/npp-wine.log; "
            "! grep -q 'Permission denied' /tmp/npp-wine.log"
        )

    with subtest("Second launch reuses layers and shows a window"):
        machine.succeed(
            "su - alice -c 'npp-vm-launch /tmp/npp-wine2.log /tmp/npp2.pid'"
        )
        machine.wait_until_succeeds(
            "grep -q 'Running Windows app' /tmp/npp-wine2.log",
            timeout=120,
        )
        machine.wait_until_succeeds(
            "su - alice -c 'DISPLAY=:0 xwininfo -root -tree | grep -qi notepad'",
            timeout=60,
        )
        machine.execute("su - alice -c npp-vm-stop || true")
        machine.wait_until_succeeds(
            "grep -q 'App exited' /tmp/npp-wine2.log",
            timeout=120,
        )
        machine.screenshot("notepad-plus-plus-wine-relaunch")
  '';
}
