{ ... }:

{
  sane.persist.stores.private.origin = "/mnt/persist/private";
  # store /home/colin/a/b in /mnt/persist/private/a/b instead of /mnt/persist/private/home/colin/a/b
  sane.persist.stores.private.prefix = "/home/colin";

  sane.persist.sys.byStore.plaintext = [
    # TODO: these should be private.. somehow
    "/var/log"
    "/var/backup"  # for e.g. postgres dumps
  ];
  sane.persist.sys.byStore.cryptClearOnBoot = [
    "/var/lib/systemd/coredump"
  ];
}
