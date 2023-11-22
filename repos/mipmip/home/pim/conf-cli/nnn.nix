{ lib, pkgs, ... }:

{
  programs.nnn = {
    enable = true;
    bookmarks = {
      D = "~/Downloads";
      n = "~/nixos";
      p = "~/Pictures";
      v = "~/Videos";
    };
    plugins = {
      mappings = {
#        c = "chksum";
        d = "dragdrop";
        D = "diffs";
#        M = "nmount";
#        n = "bulknew";
        p = "preview-tui";
#        s = "!zsh -i";
#        z = "autojump";
      };
      src = "${pkgs.nnn}/share/plugins";
    };
    extraPackages =
      with pkgs;
      let
      in
      [
        libarchive # Provides bsdtar and support for more archive formats
        pmount # For mounting disks
        udisks # For mounting disks
        xdragon # Drag and drop utility
        # preview-tui
        bat # code syntax highlighting
        imagemagick # gif previews
        ffmpegthumbnailer # video thumbnails
        ffmpeg # audio thumbnails
        libreoffice # openoffice/opendocument previews
        poppler_utils # pdf thumbnails
        #gnome-epub-thumbnailer # epub thumbnails
        fontpreview # font previews
        #glow # markdown previews
        w3m # html preview
      ];
  };

  home.sessionVariables =
    let
      archiveFormats = [
        "7z"
        "a"
        "ace"
        "alz"
        "arc"
        "arj"
        "bz"
        "bz2"
        "cab"
        "cpio"
        "deb"
        "gz"
        "jar"
        "lha"
        "lz"
        "lzh"
        "lzma"
        "lzo"
        "rar"
        "rpm"
        "rz"
        "t7z"
        "tar"
        "tbz"
        "tbz2"
        "tgz"
        "tlz"
        "txz"
        "tZ"
        "tzo"
        "war"
        "xpi"
        "xz"
        "Z"
        "zip"
      ];
    in
    {
      NNN_OPTS = "cDEix";

      NNN_OPENER = "$HOME/.config/nnn/plugins/nuke";
      # Have nuke open GUI programs
      GUI = 1;

      # FIFO to write hovered path to for live previews
      NNN_FIFO = "/tmp/nnn.fifo";
      NNN_BATTHEME = "Solarized";

      # context colors
      #NNN_COLORS = "#0a1b2c3d";
      NNN_COLORS = "1234";
      NNN_FCOLORS = "123412341111";

      # Supported archive formats
      # Needed because using bsdtar increases supported archive formats
      NNN_ARCHIVE = "\\.(${lib.strings.concatStringsSep "|" archiveFormats})$";

      # preview-tui directory icons
      NNN_ICONLOOKUP = 1;
    };
}
