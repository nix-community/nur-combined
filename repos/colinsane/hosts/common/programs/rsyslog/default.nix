# docs: <https://www.rsyslog.com/doc/index.html>
# docs: `man rsyslogd`
# i have systemd-journald -> rsyslogd
# this escapes issues i'd otherwise have persisting journald itself to disk
# since that component needs to run in initrd and before service setup.
#
# TODO: log rotation / retention policy. don't want to eat the whole HDD.
# TODO: store these logs in /var/log/...
#       and at that point it makes more sense to use a systemd service.
#       i.e. revert `3a6a5ffe014761ff23220f5b4ecb74d8a9fdb8fd`
{ config, lib, ... }:
{
  sane.programs.rsyslog = {
    persist.byStore.private = [
      ".local/share/rsyslog/logs"
    ];
    # rsyslogd can't handle $HOME or ~ or anything like that,
    # so assume a single-user install and just substitute the default user:
    fs.".config/rsyslog/rsyslog.conf".symlink.text = lib.replaceStrings
      [ "$HOME" ]
      [ "/home/${config.sane.defaultUser}" ]
      (builtins.readFile ./rsyslog.conf);

    services.rsyslogd = {
      description = "rsyslogd: ingests journald (system log) messages into persistent storage";
      partOf = [ "default" ];
      # XXX(2024-07-27): rsyslog tends to be launched early, before the logs dir has been created.
      # that's a problem all my programs are susceptible to, but hack rsyslog to wait for its log dir else it'll create it on non-persisted storage
      command = "test -L ~/.local/share/rsyslog/logs && rsyslogd -f ~/.config/rsyslog/rsyslog.conf -i ~/.local/share/rsyslog/rsyslogd.pid -n";
    };
  };
}
