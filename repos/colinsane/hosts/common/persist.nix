{ ... }:

{
  sane.persist.stores.private.origin = "/home/colin/private";
  # store /home/colin/a/b in /home/private/a/b instead of /home/private/home/colin/a/b
  sane.persist.stores.private.prefix = "/home/colin";

  sane.persist.sys.plaintext = [
    "/var/log"
    "/var/backup"  # for e.g. postgres dumps
    # TODO: move elsewhere
    "/var/lib/alsa"                # preserve output levels, default devices
    "/var/lib/colord"              # preserve color calibrations (?)
    "/var/lib/machines"            # maybe not needed, but would be painful to add a VM and forget.
    "/var/lib/systemd/backlight"   # backlight brightness
    "/var/lib/systemd/coredump"
  ];
}
