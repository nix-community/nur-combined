# wally-cli: allows flashing firmware to keyboards like ZSA Ergodox.
{ ... }:
{
  sane.programs.wally-cli = {
    # sandboxing causes it to not discover devices post-launch.
    # so you have to start wally AFTER pressing the 'flash' button.
    sandbox.extraPaths = [
      "/dev/bus/usb"
      "/sys/bus/usb"
      "/sys/devices"
    ];
  };
}
