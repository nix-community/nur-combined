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
      "nix-develop" = "nix develop -c $SHELL";
      "nix-develop-impure" = "nix develop --impure -c $SHELL";
      "nix-export-unfree" = "export NIXPKGS_ALLOW_UNFREE";
      "nix-export-insecure" = "export NIXPKGS_ALLOW_INSECURE";
    };
  };
}
