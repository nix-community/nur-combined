{ pkgs, ... }:

{
  programs = {
    home-manager = {
      enable = true;
    };
  };
  home.file.".nix-channels".source = ../assets/nix-channels;
  home.file."Makefile".source = ../assets/Makefile;
  home.packages = with pkgs; [
    direnv
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
