{
  config,
  lib,
  vaculib,
  vacuModuleType,
  ...
}:
let
  cfg = config.vacu.shell;
  # https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  colors = vaculib.shellColors;

  # TODO: reset_without_clear doesn't fully work
  # thanks colin https://git.uninsane.org/colin/nix-files/src/commit/7f5b2628016c8ca1beec417766157c7676a9c5e5/hosts/common/programs/zsh/starship.nix#L24
  # https://man.archlinux.org/man/bash.1#PROMPTING
  # \[ and \] begins and ends "a sequence of non-printing characters"
  set_color = colornum: ''\[\e[1;${toString colornum}m\]'';
  set_inverted_color = colornum: ''\[\e[1;37;${toString (colornum + 10)}m\]'';
  reset_color = ''\[\e[0m\]'';
  colornum = colors.${cfg.color};
  root_text = root: lib.optionalString root "ROOT@";
  final = root: if root then (set_inverted_color colors.red) + "!!" else "$";
  hostName = if vacuModuleType == "plain" then ''\h'' else config.vacu.shortHostName;
  default_ps1 =
    root:
    ""
    + ''\n''
    # + ''\[${reset_without_clear}\]''
    + (set_color colornum)
    + "${root_text root}${hostName}:\\w"
    + " "
    + ''$(vacu_shell_show_return_code)''
    + ''\n''
    + (set_color colornum)
    + (final root)
    + reset_color
    + " ";
in
{
  vacu.shell.idempotentShellLines = ''
    function vacu_shell_show_return_code() {
      local ret=$?
      local color=${toString colors.green}
      if [[ "$ret" != 0 ]]; then
        color=${toString colors.red}
      fi
      printf '\e[1;%dm' $color
      printf "%d" "$ret"
      return "$ret"
    }
    if [[ $EUID == 0 ]]; then
      PS1=${lib.escapeShellArg (default_ps1 true)}
    else
      PS1=${lib.escapeShellArg (default_ps1 false)}
    fi
  '';
}
