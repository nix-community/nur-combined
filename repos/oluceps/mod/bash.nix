{
  flake.modules.nixos.bash = {
    programs.bash = {
      interactiveShellInit = ''
        # # https://codeberg.org/dnkl/foot/wiki#piping-last-command-s-output
        # PS0+='\e]133;C\e\\'

        # command_done() {
        #     printf '\e]133;D\e\\'
        # }
        # PROMPT_COMMAND=''${PROMPT_COMMAND:+$PROMPT_COMMAND; }command_done
        flyline history --backend flyline
        flyline set-agent-mode \
          --system-prompt "Be concise. Answer with a JSON array of at most 3 items with objects containing: command and description. Command will be a Bash command. " \
          --trigger-prefix ': ' \
          --command 'agy --model "Gemini 3.7 Flash (Low)" --prompt'
      '';
    };
    programs.flyline = {
      enable = true;
    };
  };
}
