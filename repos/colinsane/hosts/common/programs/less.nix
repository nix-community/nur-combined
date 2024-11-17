{ ... }:
{
  sane.programs.less = {
    sandbox.autodetectCliPaths = "existingFile";
    env.PAGER = "less";
    # LESS flags:
    # - F = quit if output fits on one screen
    # - K = exit on ctrl+c
    # - M = "long prompt"
    # - R = output raw control characters
    # - S = chop long lines instead of wrapping
    # - X = Don't use termcap init/deinit strings (hence, `less` output is visible on the terminal even after exiting)
    # SYSTEMD_LESS defaults to FRSXMK
    env.LESS = "FRMK";
    env.SYSTEMD_LESS = "FRMK";  #< used by journalctl
  };
}
