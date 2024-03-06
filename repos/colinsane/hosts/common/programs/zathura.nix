{ ... }:
{
  sane.programs.zathura = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  #< wrapper sets ZATHURA_PLUGINS_PATH to $out/lib/...
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";
    persist.byStore.plaintext = [
      # history, bookmarks
      ".local/share/zathura"
    ];

    mime.associations."application/pdf" = "org.pwmt.zathura.desktop";
    mime.associations."application/vnd.comicbook+zip" = "org.pwmt.zathura.desktop";  # .cbz
    mime.associations."application/vnd.comicbook-rar" = "org.pwmt.zathura.desktop";  # .cbr
  };
}
