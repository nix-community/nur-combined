{ ... }:
{
  vacu.shell.idempotentShellLines = ''
    if [[ $- == *i* ]]; then
      # don't overwrite files by default when using > redirection
      set -o noclobber
      # disable ! history expansion
      set +o histexpand
    fi
  '';
}
