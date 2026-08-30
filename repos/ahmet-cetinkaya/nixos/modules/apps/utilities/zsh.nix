{
  imports = [
    ./fastfetch.nix
    ./starship.nix
    ../development/neovim.nix
  ];

  programs.zsh.enable = true;

  home-manager.sharedModules = [
    ({pkgs, ...}: {
      home.packages = [pkgs.eza];

      programs = {
        zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
              "sudo"
              "docker"
              "kubectl"
            ];
            theme = "robbyrussell";
          };

          shellAliases = {
            ll = "ls -l";
            ls = "eza --icons=auto --hyperlink";
          };

          initContent = ''
            source "$HOME/Configs/zsh/nixos.zshrc"
          '';
        };
      };
    })
  ];
}
