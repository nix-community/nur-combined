self: super:
let

  brh-python = self.python3.withPackages (ps: with ps; [
    ipdb
    ipython
    jupytext
    marimo
    matplotlib
    notebook
    numpy
    pandas
    pyflakes
    pylint
    python-lsp-server
    scipy
    seaborn
    selenium
    yapf
  ]);

  # nvim ships with these three parsers by default, and gets angry if we desync them from the vendored versions.
  nvim-grammars = self.lib.attrNames (removeAttrs self.vimPlugins.nvim-treesitter.grammarPlugins [ "c" "lua" "query" ]);
  brh-neovim = super.neovim.override {
    configure.customRC = "source $HOME/.config/nvim/init.lua";
    configure.packages.myPlugins.start = [
      (self.vimPlugins.nvim-treesitter.withPlugins (p: map (n: p."${n}") nvim-grammars))
    ];
  };

  lsp-tools = [
    self.pyright
  ];

in
{

  # Minimal set of packages to install everywhere
  minEnv = super.buildEnv {
    name = "minEnv";
    paths = [
      brh-neovim
      brh-python
      self.alacritty
      self.bat
      self.bc
      self.comma
      self.coreutils
      self.curl
      self.fd
      self.feh
      self.file
      self.fzf
      self.git-crypt
      self.gitui
      self.gnutar
      self.google-chrome
      self.htop
      self.hwinfo
      self.jq
      self.killall # used by i3
      self.par
      self.pass
      self.pinentry-curses
      self.ripgrep
      self.rlwrap
      self.sqlite
      self.tmux
      self.tmuxPlugins.copycat
      self.tmuxPlugins.open
      self.tmuxPlugins.sensible
      self.tmuxPlugins.yank
      self.tree
      self.unzip
      self.wget
      self.xorg.xev
      self.xorg.xeyes
      self.xorg.xmodmap
      self.zellij
      self.zoxide
      self.zsh
    ] ++ builtins.filter self.lib.attrsets.isDerivation (builtins.attrValues self.nerd-fonts);
  };

  # Packages pulled from nixos-unstable
  unstableEnv = super.buildEnv {
    name = "unstableEnv";
    paths = [
      self.claude-code
      self.freerdp
      self.yt-dlp
    ];
  };

  # For "permanent" systems
  bigEnv = super.buildEnv {
    name = "bigEnv";
    paths = lsp-tools ++ [
      self.alsa-utils
      self.anki-bin
      self.aspell
      self.autoflake
      self.bind
      self.bubblewrap
      self.chromedriver
      self.direnv
      self.discord
      self.dunst
      self.emacs
      self.expect
      self.ffmpeg
      self.flameshot
      self.gcc
      self.git
      self.git-lfs
      self.gnome-keyring
      self.gnumake
      self.gnutls
      self.graphviz
      self.icu
      self.imagemagick
      self.ledger
      self.libheif
      self.libnotify # for nofify-send
      self.mupdf
      self.nixos-option
      self.nixpkgs-fmt
      self.nixpkgs-review
      self.nload
      self.nodejs
      self.orca-slicer
      self.pavucontrol
      self.pdsh
      self.pulseaudioFull
      self.shellcheck
      self.signal-desktop
      self.snixembed
      self.sshfs
      self.vlc
      self.xclip
      self.xdotool
      self.xsel
      self.zlib
      self.zoom-us
    ];
  };
}
