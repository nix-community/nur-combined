{

  home.file = {
    ".pandoc" = {
      source = ./.pandoc;
      recursive = true;
    };
  };

  home.file = {
    ".tmux" = {
      source = ./.tmux;
      recursive = true;
    };
  };

  home.file = {
    ".vim" = {
      source = ./.vim;
      recursive = true;
    };
  };

  home.file = {
    ".config/smug" = {
      source = ./smug;
      recursive = true;
    };
  };

# NOTE archived
#  home.file = {
#    ".config/wtf" = {
#      source = ./wtf;
#      recursive = true;
#    };
#  };

  home.file = {
    "./.ansible.cfg" = {
      source = ./.ansible.cfg;
    };
  };

  home.file = {
    "./.config/alacritty.yml" = {
      source = ./alacritty.yml;
    };
  };

  home.file = {
    ".config/skulls.yaml" = {
      source = ./skulls.yaml;
    };
  };

}
