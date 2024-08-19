{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set pure_enable_single_line_prompt true
      ${pkgs.thefuck}/bin/thefuck --alias | source
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
    };

    shellAbbrs = {
      gc1 = "git clone --depth=1 ";
    };
    plugins = [
      # {
      #   name = "pure";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "pure-fish";
      #     repo = "pure";
      #     rev = "f1b2c7049de3f5cb45e29c57a6efef005e3d03ff";
      #     hash = "sha256-MnlqKRmMNVp6g9tet8sr5Vd8LmJAbZqLIGoDE5rlu8E=";
      #   };
      # }
      {
        name = "auto-venv";
        src = pkgs.fetchFromGitHub {
          owner = "nakulj";
          repo = "auto-venv";
          rev = "ec9ff89d9887e87fbf4ce22812163770b102295a";
          hash = "sha256-x9HzTBhpmoH/UeAOMj0f8LYTrQuhNElWa2gBEjol/h8=";
        };
      }
    ];
  };
}
