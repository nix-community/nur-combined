{ pkgs, ... }:

{
  programs = {
    home-manager = {
      enable = true;
    };
  };
  home.file.".nix-channels".source = ../assets/nix-channels;
  home.packages = with pkgs; [
    enchive
    entr
    exa
    fd
    htop
    mpw
    ncurses
    scripts
    tree
  ];
  programs.direnv.enable = true;
  programs.direnv.stdlib = ''
    mkdir -p $HOME/.cache/direnv/layouts
    pwd_hash=$(echo -n $PWD | shasum | cut -d ' ' -f 1)
    direnv_layout_dir=$HOME/.cache/direnv/layouts/$pwd_hash
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
  xdg.configFile."nr/default" = {
    text = builtins.toJSON [
      { cmd = "ncdu"; }
      { cmd = "sshfs"; }
      { cmd = "gotop"; }
      { cmd = "pandoc"; }
      { cmd = "dust"; pkg = "du-dust"; }
      { cmd = "bandwhich"; }
      { cmd = "lspci"; pkg = "pciutils"; }
      { cmd = "lsusb"; pkg = "usbutils"; }
      { cmd = "9"; pkg = "plan9port"; }
      { cmd = "wakeonlan"; pkg = "python36Packages.wakeonlan"; }
      { cmd = "beet"; pkg = "beets"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr default";
  };
}
