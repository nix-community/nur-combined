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
        # libwindowsapp.bash calls `fusermount` (fuse2 name); provide a shim.
        (pkgs.writeShellScriptBin "fusermount" ''
          exec /run/wrappers/bin/fusermount3 "$@"
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

    with subtest("Wine Notepad++ installs bottle and starts under X11"):
        # Skip winetricks cjkfonts in the VM (slow / network-heavy).
        # Run under timeout in the foreground so su cannot SIGHUP the launcher.
        # 124 from timeout(1) means the UI was still running after 60s.
        # Guard against set -e aborting on timeout's 124 before assertions.
        machine.succeed(
            "set +e; "
            "su - alice -c '"
            "export PATH=/run/wrappers/bin:$PATH; "
            "echo \"Xft.dpi: 96\" | xrdb -merge; "
            "NOTEPADPP_SKIP_CJKFONTS=1 DISPLAY=:0 timeout -k 5 60 notepad-plus-plus"
            "' >/tmp/npp-wine.log 2>&1; "
            "ec=$?; set -e; "
            "echo launcher-exit=$ec >> /tmp/npp-wine.log; "
            "cat /tmp/npp-wine.log; "
            "grep -q 'Windows and app layers are initialized' /tmp/npp-wine.log; "
            "grep -q 'Running Windows app' /tmp/npp-wine.log; "
            "! grep -q 'fusermount: command not found' /tmp/npp-wine.log; "
            "! grep -q 'mount failed: Operation not permitted' /tmp/npp-wine.log; "
            "[ \"$ec\" = 124 ] || [ \"$ec\" = 0 ] || grep -q 'App exited' /tmp/npp-wine.log",
            timeout=timedelta(minutes=10),
        )
        machine.execute("su - alice -c 'DISPLAY=:0 xwininfo -root -tree' >/tmp/xwin-wine.txt || true")
        print(machine.succeed("cat /tmp/xwin-wine.txt || true"))
        machine.screenshot("notepad-plus-plus-wine")
  '';
}
