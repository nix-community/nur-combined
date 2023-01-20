{ pkgs, ... }:

{
  packages = {
    cli = with pkgs; [
      tree
      p7zip
    ];
    dev = [ pkgs.shellcheck ];
    gaming = with pkgs; [ protontricks winetricks ];
    gui = with pkgs; [
      calibre
      keepassxc
      libreoffice
      qbittorrent
      raven-reader
      thunderbird
      vlc
    ];
    work = [];
  };

  mimelist = {
    "application/xml" = "neovim.desktop";
    "application/x-perl" = "neovim.desktop";
    "image/jpeg" = "feh.desktop";
    "image/png" = "feh.desktop";
    "text/mathml" = "neovim.desktop";
    "text/plain" = "neovim.desktop";
    "text/xml" = "neovim.desktop";
    "text/x-c++hdr" = "neovim.desktop";
    "text/x-c++src" = "neovim.desktop";
    "text/x-xsrc" = "neovim.desktop";
    "text/x-chdr" = "neovim.desktop";
    "text/x-csrc" = "neovim.desktop";
    "text/x-dtd" = "neovim.desktop";
    "text/x-java" = "neovim.desktop";
    "text/x-python" = "neovim.desktop";
    "text/x-sql" = "neovim.desktop";
    "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;" = "neovim.desktop";
     "x-scheme-handler/http" = "firefox.desktop";
     "x-scheme-handler/https" = "firefox.desktop";
     "x-scheme-handler/about" = "firefox.desktop";
     "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
