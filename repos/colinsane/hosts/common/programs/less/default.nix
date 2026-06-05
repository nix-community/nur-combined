{ ... }:
{
  sane.programs.less = {
    sandbox.autodetectCliPaths = "existingFile";
    # LESS flags:
    # - --LINE-NUMBERS (N) = render EVERY line with its number in the left column
    # - --LONG-PROMPT (M) = "long prompt"
    # - --RAW-CONTROL-CHARS (R) = output raw control characters
    # - --chop-long-lines (S) = chop long lines instead of wrapping
    # - --incsearch = start searching immediately as you type `/<search-term>`
    # - --no-init (X) = Don't use termcap init/deinit strings (hence, `less` output is visible on the terminal even after exiting)
    # - --quit-if-one-screen (F) = quit if output fits on one screen
    # - --quit-on-intr (K) = exit on ctrl+c
    # - --shift=.n = left/right arrow-keys scroll by `n` screen widths
    # - --use-color = enable color instead of just monochrome (highlights search matches)
    # SYSTEMD_LESS defaults to FRSXMK
    env = rec {
      # MANPAGER = "less";
      PAGER = "less";
      LESS = "--incsearch --LONG-PROMPT --quit-if-one-screen --quit-on-intr --RAW-CONTROL-CHARS --shift=.2 --use-color";
      SYSTEMD_LESS = LESS;  #< used by journalctl
    };
    mime.priority = 200;  # fallback to more specialized pagers where exists
  };
}
