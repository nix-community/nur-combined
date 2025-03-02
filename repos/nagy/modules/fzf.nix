{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fzf ];

  # if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "29.1,eat") ]]; then
  programs.bash.interactiveShellInit = ''
    if [[ $TERM != "dumb" ]]; then
      if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
        . ${pkgs.fzf}/share/fzf/completion.bash
        . ${pkgs.fzf}/share/fzf/key-bindings.bash
      fi
    fi
  '';

  # programs.fzf = {
  #   fuzzyCompletion = true;
  #   keybindings = true;
  # };
}
