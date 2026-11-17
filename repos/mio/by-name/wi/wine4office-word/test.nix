{
  wine4office-word,
  wine4office,
  nixpkgsPath,
  installWord ? false,
}:
{
  name = if installWord then "wine4office-word" else "wine4office";
  meta.timeout = if installWord then 7200 else 900;
  globalTimeout = if installWord then 7200 else 900;

  nodes.machine = { pkgs, lib, ... }: {
    imports = [
      "${nixpkgsPath}/nixos/tests/common/x11.nix"
      "${nixpkgsPath}/nixos/tests/common/user-account.nix"
    ];
    test-support.displayManager.auto.user = "alice";
    hardware.graphics.enable = true;
    # The test framework removes these by default. Only the live CDN test
    # needs QEMU's user-network gateway and DNS resolver.
    networking = lib.mkIf installWord {
      defaultGateway = {
        address = "10.0.2.2";
        interface = "eth0";
      };
      nameservers = [ "10.0.2.3" ];
    };
    environment.systemPackages = [
      wine4office
      wine4office-word
      pkgs.xdotool
      pkgs.procps
    ];
    virtualisation = {
      memorySize = 8192;
      diskSize = 32768;
      cores = 4;
      restrictNetwork = !installWord;
    };
  };

  testScript = ''
    from datetime import timedelta

    start_all()
    machine.wait_for_x()

    def user(command, timeout=300):
        import shlex
        return machine.succeed("su - alice -c " + shlex.quote(
            "export DISPLAY=:0 WINEPREFIX=$HOME/.wine4office WINEDEBUG=-all; " + command
        ), timeout=timedelta(seconds=timeout))

    with subtest("Wine initializes a 64-bit prefix and runs Windows commands"):
        user("wine wineboot --init && wineserver -w")
        assert "wine-" in user("wine --version")
        assert "WINE4OFFICE_OK" in user("wine cmd /c echo WINE4OFFICE_OK")
        user("test -f ~/.wine4office/drive_c/windows/system32/kernel32.dll")
        user("test -f ~/.wine4office/drive_c/windows/syswow64/kernel32.dll")
        user("wine4office-install-word --help")

    ${
      if installWord then
        ''
          with subtest("Install Microsoft Word from Microsoft's CDN"):
              try:
                  user("wine4office-install-word > /tmp/word-install.log 2>&1", timeout=5400)
              finally:
                  print(machine.succeed("cat /tmp/word-install.log"))
                  machine.screenshot("word-install")
              user("test -s '.wine4office/drive_c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE'")

          with subtest("Microsoft Word opens a document and survives relaunch"):
              user("printf '{\\\\rtf1\\\\ansi Wine4Office VM document test}' > /home/alice/word-test.rtf")
              for launch in range(2):
                  user("nohup wine4office-word /q /a Z:/home/alice/word-test.rtf > /tmp/word-launch.log 2>&1 < /dev/null &")
                  try:
                      machine.wait_until_succeeds(
                          "su - alice -c 'DISPLAY=:0 xdotool search --onlyvisible --name \"word-test.*Microsoft Word\"'",
                          timeout=timedelta(minutes=5),
                      )
                      user("pgrep -u alice -x WINWORD.EXE")
                      machine.sleep(timedelta(seconds=10))
                      user("xdotool search --onlyvisible --name \"word-test.*Microsoft Word\"")
                      machine.screenshot("word-document-" + str(launch + 1))
                  except Exception:
                      print(user("xdotool search --onlyvisible --name . getwindowname || true"))
                      machine.screenshot("word-launch-failure-" + str(launch + 1))
                      raise
                  finally:
                      print(machine.succeed("cat /tmp/word-launch.log"))
                      user("wineserver -k; wineserver -w")
                      # Let Office's Click-to-Run service and prefix fully settle
                      # before the next launch; otherwise the relaunch races it.
                      machine.sleep(timedelta(seconds=5))
        ''
      else
        ''
          with subtest("Missing Word produces a helpful error"):
              user("if wine4office-word > /tmp/word-missing.log 2>&1; then exit 1; fi")
              user("grep -F 'Run wine4office-install-word first.' /tmp/word-missing.log")
              user("wineserver -k; wineserver -w")
        ''
    }
  '';
}
