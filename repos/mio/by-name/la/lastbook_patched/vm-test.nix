{ lastbook, pkgs }:
pkgs.testers.nixosTest {
  name = "lastbook-patched-setup";

  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        lastbook
        xvfb
        xwininfo
        xdotool
        imagemagick
        dejavu_fonts
      ];
      services.xserver.enable = true;
      virtualisation = {
        memorySize = 4096;
        diskSize = 8192;
        cores = 2;
      };
      environment.variables = {
        LIBGL_ALWAYS_SOFTWARE = "1";
        WEBKIT_DISABLE_COMPOSITING_MODE = "1";
      };
    };

  # The disk is smaller than even Small needs, so setup shows "Not enough room"
  # and the patched "Continue anyway" checkbox; scroll down to capture the summary.
  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.execute("Xvfb :99 -screen 0 1400x900x24 >/tmp/xvfb.log 2>&1 &")
    machine.wait_until_succeeds("test -S /tmp/.X11-unix/X99")
    machine.execute("DISPLAY=:99 lastbook >/tmp/lastbook.log 2>&1 &")
    machine.wait_until_succeeds("DISPLAY=:99 xwininfo -root -tree | grep -qi lastbook", timeout=180)
    machine.sleep(20)
    machine.execute("DISPLAY=:99 xdotool search --onlyvisible --name Lastbook windowactivate --sync")
    machine.sleep(1)
    machine.execute("DISPLAY=:99 xdotool mousemove 700 200 click 1")
    machine.sleep(1)
    machine.execute("DISPLAY=:99 xdotool key --clearmodifiers End")
    machine.sleep(2)
    machine.execute("DISPLAY=:99 import -window root /tmp/setup.png")
    machine.copy_from_machine("/tmp/setup.png")
    machine.copy_from_machine("/tmp/lastbook.log")
  '';
}
