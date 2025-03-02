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
      {
        name = "auto-venv";
        src = pkgs.fetchFromGitHub {
          owner = "nakulj";
          repo = "auto-venv";
          rev = "3bf8fff2b688ee1ccd4a6ed1bc1250ced2ab30f1";
          hash = "sha256-7+Wdyg8Icp+6S7+PiW5DVRNnLBtzJ/OI3uIElkU3Yf0=";
        };
      }
    ];
  };
}
