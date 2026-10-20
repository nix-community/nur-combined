{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set pure_enable_single_line_prompt true
    '';
    functions = {
      __fish_command_not_found_handler = {
        body = "__fish_default_command_not_found_handler $argv[1]";
        onEvent = "fish_command_not_found";
      };
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      fish_title = ''
        echo $argv[1] ' '
        echo (prompt_pwd)
        echo " fish"
      '';
      v = {
        description = "Start a systemd-nspawn machine, optionally entering it";
        body = ''
          set -l enter_machine false
          set -l machine

          switch (count $argv)
            case 1
              set machine $argv[1]
            case 2
              if test "$argv[1]" != "-s"
                echo "usage: v [-s] <machine>" >&2
                return 2
              end
              set enter_machine true
              set machine $argv[2]
            case '*'
              echo "usage: v [-s] <machine>" >&2
              return 2
          end

          sudo ${pkgs.systemd}/bin/machinectl start -- $machine
          or return $status

          if $enter_machine
            sudo ${pkgs.systemd}/bin/machinectl shell "zzzsy@$machine"
          end
        '';
      };
    };

    shellAbbrs = {
      gc1 = "git clone --depth=1";
      rsy = "rsync -avz --partial --progress";
    };
    plugins = [
      {
        name = "auto-venv";
        src = pkgs.fetchFromGitHub {
          owner = "nakulj";
          repo = "auto-venv";
          rev = "3bf8fff2b688ee1ccd4a6ed1bc1250ced2ab30f1";
          hash = "sha256-7+Wdyg8Icp+6S7+PiW5DVRNnLBtzJ/OI3uIElkU3Yf0=";
        };
      }
      # {
      #   name = "fish-async-prompt";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "acomagu";
      #     repo = "fish-async-prompt";
      #     rev = "b90e8a8c6d1634d8f04f1532b164b99530445159";
      #     hash = "sha256-HWW9191RP//48HkAHOZ7kAAAPSBKZ+BW2FfCZB36Y+g=";
      #   };
      # }
    ];
  };
}
