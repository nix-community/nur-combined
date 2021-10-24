# manage files in ~

{

  home.file = {
    ".pake" = {
      source = ./.pake;
      recursive = true;
    };
  };

  home.file = {
    ".pandoc" = {
      source = ./.pandoc;
      recursive = true;
    };
  };

  home.file = {
    ".pim-macos-housekeeping" = {
      source = ./.pim-macos-housekeeping;
      recursive = true;
    };
  };

  home.file = {
    ".screenlayout" = {
      source = ./.screenlayout;
      recursive = true;
    };
  };

  home.file = {
    ".tmux" = {
      source = ./.tmux;
      recursive = true;
    };
  };


#  home.file = {
    #".vimrc" = {
      #source = ./.vimrc;
    #};
#  };

  home.file = {
    ".vim" = {
      source = ./.vim;
      recursive = true;
    };
  };
#  home.file = {
    #".vim/vimrc" = {
      #source = ./.vimrc;
    #};
#  };

  home.file = {
    ".vimcleanfortesting" = {
      source = ./.vimcleanfortesting;
      recursive = true;
    };
  };

  home.file = {
    ".zsh.d" = {
      source = ./.zsh.d;
      recursive = true;
    };
  };

  home.file = {
    ".config/awesome" = {
      source = ./awesome;
      recursive = true;
    };
  };

  home.file = {
    ".config/smug" = {
      source = ./smug;
      recursive = true;
    };
  };

  home.file = {
    ".config/vifm" = {
      source = ./vifm;
      recursive = true;
    };
  };

  home.file = {
    ".config/wtf" = {
      source = ./wtf;
      recursive = true;
    };
  };

  home.file = {
    "./.fzf.bash" = {
      source = ./.fzf.bash;
    };
  };

  home.file = {
    "./.fzf.zsh" = {
      source = ./.fzf.zsh;
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
    "./.pit-add-files" = {
      source = ./.pit-add-files;
    };
  };
  home.file = {
    "./.pitstart.sh" = {
      source = ./.pitstart.sh;
    };
  };
  home.file = {
    "./.tmux.conf" = {
      source = ./.tmux.conf;
    };
  };

  home.file = {
    "./.Xmodmap" = {
      source = ./.Xmodmap;
    };
  };
  home.file = {
    "./.Xresources" = {
      source = ./.Xresources;
    };
  };
  home.file = {
    "./.zlogin" = {
      source = ./.zlogin;
    };
  };
  home.file = {
    "./.zprofile" = {
      source = ./.zprofile;
    };
  };
  home.file = {
    "./.zshenv" = {
      source = ./.zshenv;
    };
  };
  home.file = {
    "./.zshrc" = {
      source = ./.zshrc;
    };
  };
  home.file = {
    "./.config/alacritty.yml" = {
      source = ./alacritty.yml;
    };
  };
  home.file = {
    "./.config/compton.conf" = {
      source = ./compton.conf;
    };
  };
  home.file = {
    "./.config/picom.conf" = {
      source = ./picom.conf;
    };
  };

  home.file = {
    "./Rakefile" = {
      source = ./Rakefile;
    };
  };
}
