# TODO: hack readline to use a _real_ vim:
# <https://github.com/ardagnir/athame>
{ ... }:
{
  sane.programs.readline = {
    packageUnwrapped = null;  # this 'program' is a library: we only care to ship the _config_.
    fs.".inputrc".symlink.target = ".config/readline/inputrc";
    fs.".config/readline/inputrc".symlink.text = ''
      # docs: <https://tiswww.case.edu/php/chet/readline/readline.html>
      #
      # readline tries to load the following locations, short-circuiting on success:
      # - ''${INPUTRC:-~/.inputrc}
      # - /etc/inputrc

      # optional debugging: `@` indicates emacs, `(ins)` indicates vi, etc.
      # set show-mode-in-prompt on

      # older readline seems liable to break Ctrl+A, Ctrl+E, etc in vi mode.
      $if version >= 8.3
      set editing-mode vi
      $endif

      set blink-matching-paren on
      set colored-completion-prefix on
      set colored-stats on
      set mark-symlinked-directories on
      # TODO: print completions in reading order, but only after i configure `ls`/`eza` to do the same.
      # set print-completions-horizontally on
      set show-all-if-ambiguous on

      $include /etc/inputrc
    '';
  };
}
