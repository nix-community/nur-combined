{ pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./htop.nix
    ./ssh.nix
    ./tmux.nix
    ./xdg.nix
    ./zsh.nix
  ];

  home = {
    stateVersion = "20.03";
    packages = with pkgs; [
      enchive
      entr
      exa
      fd
      htop
      mpw
      mosh
      ncurses
      ripgrep
      scripts
      tree
      youtube-dl
      my.batzconverter
    ];
  };

  xdg.configFile."ape.conf".source = ./ape/ape.conf;
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    }
  '';
  xdg.configFile."nr/default" = {
    text = builtins.toJSON [
      { cmd = "ncdu"; }
      { cmd = "sshfs"; }
      { cmd = "lspci"; pkg = "pciutils"; }
      { cmd = "lsusb"; pkg = "usbutils"; }
      { cmd = "9"; pkg = "plan9port"; }
      { cmd = "wakeonlan"; pkg = "python36Packages.wakeonlan"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr default";
  };
}
