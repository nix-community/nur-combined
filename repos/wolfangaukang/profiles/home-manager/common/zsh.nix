{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "linuxonly";
    };
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      ".." = "cd ..";
    };
  };
}
