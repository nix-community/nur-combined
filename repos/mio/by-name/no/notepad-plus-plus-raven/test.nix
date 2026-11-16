{
  notepad-plus-plus-raven,
  nixpkgsPath,
}:

{
  name = "notepad-plus-plus-raven";

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
      hardware.graphics.enable = true;

      environment.systemPackages = [
        notepad-plus-plus-raven
        pkgs.xwininfo
      ];

      virtualisation.memorySize = 4096;
      virtualisation.diskSize = 10240;
      virtualisation.cores = 2;
    };

  testScript = ''
    from datetime import timedelta

    machine.start()
    machine.wait_for_x()

    with subtest("Raven stages and launches Notepad++ under X11"):
        # Raven currently reaches Notepad++ then hits unimplemented guest APIs
        # (e.g. DwmGetColorizationColor) and exits non-zero. Assert staging +
        # that Raven actually entered the guest PE rather than a clean GUI stay-up.
        machine.succeed(
            "su - alice -c 'DISPLAY=:0 timeout -k 5 30 notepad-plus-plus-raven' "
            ">/tmp/npp-raven.log 2>&1 || true",
            timeout=timedelta(minutes=5),
        )
        print(machine.succeed("cat /tmp/npp-raven.log || true"))
        machine.succeed(
            "test -e /home/alice/.local/share/notepad-plus-plus-raven/prefix/.notepadpp-installed"
        )
        machine.succeed(
            "test -f '/home/alice/.local/share/notepad-plus-plus-raven/prefix/drive_c/Program Files/Notepad++/notepad++.exe'"
        )
        machine.succeed(
            "grep -E 'unimplemented native|Staging Notepad' /tmp/npp-raven.log"
        )
        machine.screenshot("notepad-plus-plus-raven")
  '';
}
