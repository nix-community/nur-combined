{ ... }:
{
  sane.programs.gocryptfs = {
    sandbox.method = "landlock";
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [
      # CAP_SYS_ADMIN is only required if directly invoking gocryptfs
      # i.e. not leverage a mount helper like `mount.fuse3-sane`.
      "sys_admin"
      "chown"
      "dac_override"
      "dac_read_search"
      "fowner"
      "lease"
      "mknod"
      "setgid"
      "setuid"
    ];
    suggestedPrograms = [
      "util-linux"  #< gocryptfs complains that it can't exec `logger`, otherwise
    ];
  };
}
