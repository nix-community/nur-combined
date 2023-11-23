{ lib, pkgs, unstable, ... }:

{
  programs.nnn = {
    package = unstable.nnn;
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
      src = "${unstable.nnn}/share/plugins";
    };
    extraPackages = [];
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

      NNN_TRASH = 1;

      # context colors
      #NNN_COLORS = "#0a1b2c3d";
      NNN_COLORS = "1234";
      NNN_FCOLORS = "123412341111";

      NNN_PREVIEWIMGPROG = "catimg";
      # Supported archive formats
      # Needed because using bsdtar increases supported archive formats
      NNN_ARCHIVE = "\\.(${lib.strings.concatStringsSep "|" archiveFormats})$";

      # preview-tui directory icons
      NNN_ICONLOOKUP = 1;
    };
}
