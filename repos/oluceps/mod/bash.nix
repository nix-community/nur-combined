{
  flake.modules.nixos.bash = {
    programs.bash = {
      blesh.enable = true;
      interactiveShellInit = ''
        # https://codeberg.org/dnkl/foot/wiki#piping-last-command-s-output
        PS0+='\e]133;C\e\\'

        command_done() {
            printf '\e]133;D\e\\'
        }
        PROMPT_COMMAND=''${PROMPT_COMMAND:+$PROMPT_COMMAND; }command_done
      '';
    };
  };
}
