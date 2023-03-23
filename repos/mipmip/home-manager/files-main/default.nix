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
    "./.lindex.yml" = {
      source = ./.lindex.yml;
    };
  };

  home.file = {
    "./.lindex_dev.yml" = {
      source = ./.lindex_dev.yml;
    };
  };

  home.file = {
    "./.config/alacritty.yml" = {
      source = ./alacritty.yml;
    };
  };

}
