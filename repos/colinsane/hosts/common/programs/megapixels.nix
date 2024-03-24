{ ... }:
{
  sane.programs.megapixels = {
    # megapixels sandboxing is tough:
    # if misconfigured, preview will alternately be OK, black, or only 1/4 of it will be rendered -- with no obvious pattern.
    # adding all of ~ to the sandbox will sometimes (?) fix the flakiness, even when `strace` doesn't show it accessing any files...
    # it might just be that megapixels is sensitive to low perf. e.g. it's racy
    #
    # further, it doesn't use either portals or xdg-open to launch the image viewer.
    # bwrap (loupe image viewer) doesn't like to run inside landlock
    #   "bwrap: failed to make / slave: Operation not permitted"
    sandbox.method = "bwrap";  # supports landlock or bwrap
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  #< so that it can in theory open the image viewer using fdo portal... but it doesn't :|
    sandbox.extraHomePaths = [
      ".config/dconf"  #< else it segfaults during post-process
      # ".config/megapixels"
      ".local/share/applications"  #< needed for viewing photos, until i can sort out the portal stuff
      ".cache/mesa_shader_cache"  # loads way faster
      "tmp"
      "Pictures"  #< TODO: make this Pictures/Photos and save photos there
      # also it addresses a lot via relative path.
    ];
    sandbox.extraPaths = [
      # needs /dev/media*, /dev/video*; easier to give it all of /dev which isn't that bad since it's not running as root.
      "/dev"
      # it passes the raw .dng files to a post-processor, via /tmp
      "/tmp"
      "/sys/class/leds"  #< for flash, presumably
      # "/sys/dev/char"  #< not strictly necessary? but referenced in the source (for 1.7.0, not 1.8.0)
      "/sys/devices"
      "/sys/firmware"
      # source code references /proc/device-tree/compatible, but it seems to be alright either way
      "/proc"
    ];
    sandbox.extraRuntimePaths = [
      "dconf"  #< else it's very spammy, and slow
    ];
    suggestedPrograms = [ "dconf" ];  #< not sure if necessary
  };
}
