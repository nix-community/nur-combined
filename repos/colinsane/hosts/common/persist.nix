{ ... }:

{
  sane.persist.stores.private.origin = "/home/colin/private";
  # store /home/colin/a/b in /home/private/a/b instead of /home/private/home/colin/a/b
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
