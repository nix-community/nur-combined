{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.starship;
in
{
  environment.sessionVariables.STARSHIP_CONFIG =
    (pkgs.writeText "starship-config.toml" ''
      add_newline=false
      [line_break]
      disabled = true
      ${lib.pipe "${cfg.package}/share/starship/presets/plain-text-symbols.toml" [
        lib.readFile
        # mkDollarPrompt
        (lib.replaceStrings [ ">](bold green)" ] [ "\\\\$](bold green)" ])
        # mkGitBranch
        (lib.replaceStrings [ "[git_branch]\n" ] [ "[git_branch]\nignore_branches = ['master', 'main']\n" ])
      ]}
    '').outPath;

  # Simpler version of starship init script until
  # https://github.com/starship/starship/issues/896 is fixed
  programs.bash.interactiveShellInit = ''
    if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS =~ ,eat) ]]; then
      if [[ -w /run/user/$UID ]] ; then
        export STARSHIP_CACHE=/run/user/$UID/starship-cache
      fi
      eval "$(${cfg.package}/bin/starship init bash --print-full-init)"
    fi
    [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
      source "$EAT_SHELL_INTEGRATION_DIR/bash"
  '';

  # The starship binary could also be added to system packages. This
  # is needed when using prompt explanations and timings
  environment.systemPackages = [ cfg.package ];
}
