{ ... }:
{
  sane.programs.gocryptfs = {
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [
      # CAP_SYS_ADMIN is only required if directly invoking gocryptfs.
      # it's not *necessarily* required if using a mount helper like `mount.fuse3-sane`
      # however if using a namespace-based sandbox method (bunpen, bwrap), and you wish
      # to preserve user mappings, it's still required.
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
    sandbox.tryKeepUsers = true;
    sandbox.keepPids = true;
    suggestedPrograms = [
      "util-linux"  #< gocryptfs complains that it can't exec `logger`, otherwise. TODO(2024-09-09): is this still needed?
    ];
  };
}
