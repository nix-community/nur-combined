{
  flightdeck,
  nixpkgsPath,
}:

{
  name = "flightdeck";
  meta.timeout = 1200;

  nodes.machine =
    { pkgs, ... }:
    {
      imports = [
        "${nixpkgsPath}/nixos/tests/common/x11.nix"
        "${nixpkgsPath}/nixos/tests/common/user-account.nix"
      ];

      test-support.displayManager.auto.user = "alice";

      environment.systemPackages = [
        flightdeck
        pkgs.xvfb
        pkgs.xwininfo
        pkgs.imagemagick
        pkgs.dejavu_fonts
      ];

      # iced is built with tiny-skia here, so the UI renders in software.
      environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";

      virtualisation = {
        memorySize = 4096;
        diskSize = 8192;
        cores = 2;
      };
    };

  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")

    with subtest("CLI reports the packaged version"):
        version = machine.succeed("su alice -c 'flightdeck --version'").strip()
        assert version == "flightdeck ${flightdeck.version}", version

    with subtest("libX11 resolves through the launcher's own RUNPATH"):
        machine.execute(
            "Xvfb :99 -screen 0 1400x900x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &"
        )
        machine.wait_until_succeeds("test -S /tmp/.X11-unix/X99")
        probe = machine.succeed(
            "su alice -c 'DISPLAY=:99 flightdeck --native-probe display'"
        )
        # The probe dlopens libX11.so.6 by soname; only the RUNPATH added in
        # postFixup makes that resolve without a wrapper or LD_LIBRARY_PATH.
        assert '"state":"ready"' in probe, probe

    with subtest("desktop UI opens a Flightdeck window"):
        machine.execute("install -d -o alice -g users -m 0700 /run/user/alice")
        machine.execute(
            "su alice -c 'DISPLAY=:99 XDG_RUNTIME_DIR=/run/user/alice "
            "flightdeck >/tmp/flightdeck.log 2>&1 &'"
        )
        machine.wait_until_succeeds(
            "DISPLAY=:99 xwininfo -root -tree | grep -qi flightdeck", timeout=180
        )
        machine.sleep(10)
        machine.execute("DISPLAY=:99 import -window root /tmp/flightdeck-window.png")
        machine.copy_from_machine("/tmp/flightdeck-window.png")
        machine.succeed("su alice -c 'pgrep -x flightdeck'")
        launcher_output = machine.succeed("cat /tmp/flightdeck.log")
        print(launcher_output)
        assert "panicked" not in launcher_output, launcher_output
        assert "Flightdeck: " not in launcher_output, launcher_output
        machine.execute("pkill -x flightdeck || true")
  '';
}
