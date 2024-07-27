{ ... }:

{
  sane.persist.sys.byStore.initrd = [
    "/var/log"
  ];
  sane.persist.sys.byStore.plaintext = [
    # TODO: these should be private.. somehow
    "/var/backup"  # for e.g. postgres dumps
  ];
  sane.persist.sys.byStore.ephemeral = [
    "/var/lib/systemd/coredump"
  ];
}
