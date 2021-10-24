{ config, lib, pkgs, ... }:

{

  time.timeZone = "Europe/Amsterdam";
  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
  services.cron.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.variables = {
    EDITOR = "vim";
  };

  home-manager.useGlobalPkgs = true;

  users.users.pim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.pim = {

    imports = [
      ../home/files

      ## werkt nog niet, zie https://github.com/nix-community/home-manager/issues/2106
      ../home/dconf
    ];

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ ultisnips ];
      settings = {
        ignorecase = true;
      };

      extraConfig = ''

        if has('python3')
        endif

        for f in split(glob('~/.vim/base*.vim'), '\n')
          exe 'source' f
        endfor

        if has('gui_running')
          for f in split(glob('~/.vim/gui*.vim'), '\n')
            exe 'source' f
          endfor
        else
          for f in split(glob('~/.vim/cli*.vim'), '\n')
            exe 'source' f
          endfor
        endif

        for f in split(glob('~/.vim/last*.vim'), '\n')
          exe 'source' f
        endfor

      '';
    };

    programs.git = {
      enable = true;
      userName = "Pim Snel";
      userEmail = "post@pimsnel.com";
    };
  };

  home-manager.users.root = {
    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins=["git" "tmux" "docker" "python" "vi-mode" "systemd" ];
      };
    };

    programs.vim = {
      enable = true;
      settings = {
        relativenumber = false;
        number = false;
      };
      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
    };
  };

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

}
