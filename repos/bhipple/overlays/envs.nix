self: super: let

  brh-python = self.python3.withPackages(ps: with ps; [
    pyflakes
    pyls-isort
    python-language-server
    yapf
  ]);

in
{

  # Minimal set of packages to install everywhere
  minEnv = super.hiPrio (
    super.buildEnv {
      name = "minEnv";
      paths = [
        brh-python
        self.bat
        self.bc
        self.coreutils
        self.curl
        self.fd
        self.feh
        self.file
        self.fzf
        self.git-crypt
        self.gnused
        self.gnutar
        self.htop
        self.jq
        self.par
        self.pass
        self.pinentry
        self.ripgrep
        self.rlwrap
        self.tmux
        self.tmuxPlugins.copycat
        self.tmuxPlugins.open
        self.tmuxPlugins.sensible
        self.tmuxPlugins.yank
        self.tree
        self.unzip
        self.vim_configurable
        self.wget
        self.xorg.xmodmap
        self.xterm
        self.zoxide
        self.zsh
      ];
    }
  );

  # For "permanent" systems
  bigEnv = super.hiPrio (
    super.buildEnv {
      name = "bigEnv";
      paths = [
        self.alsaUtils
        self.anki
        self.aspell
        self.autoflake
        self.bind
        self.cachix
        self.chromium
        self.clang-tools
        self.dasht
        self.direnv
        self.discord
        self.dunst
        self.gitAndTools.gitFull
        self.gitAndTools.hub
        self.gnumake
        self.gnupg
        self.gnutls
        self.graphviz
        self.icu
        self.imagemagick
        self.irssi
        self.ledger
        self.libnotify # for nofify-send
        self.mupdf
        self.nixops
        self.nixpkgs-fmt
        self.nixpkgs-review
        self.nload
        self.pavucontrol
        self.pdsh
        self.remmina
        self.shellcheck
        self.source-code-pro
        self.truecrypt
        self.vlc
        self.wally-cli
        self.xclip
        self.xsel
        self.youtube-dl
        self.zlib
      ];
    }
  );
}
