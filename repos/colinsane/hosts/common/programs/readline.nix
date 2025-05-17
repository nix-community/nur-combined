{ ... }:
{
  sane.programs.readline = {
    packageUnwrapped = null;  # this 'program' is a library: we only care to ship the _config_.
    fs.".inputrc".symlink.text = ''
      # docs: <https://tiswww.case.edu/php/chet/readline/readline.html>

      set blink-matching-paren on
      set colored-completion-prefix on
      set colored-stats on
      set editing-mode vi
      set mark-symlinked-directories on
      # TODO: print completions in reading order, but only after i configure `ls`/`eza` to do the same.
      # set print-completions-horizontally on
      set show-all-if-ambiguous on
    '';
  };
}
