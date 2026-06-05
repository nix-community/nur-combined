{ pkgs, ... }: {
  sane.programs.zeal = {
    # packageUnwrapped = pkgs.zeal-qt6;  #< TODO: upgrade system to qt6 versions of everything (i.e. jellyfin-media-player, nheko)
    packageUnwrapped = pkgs.zeal-qt5;
    buildCost = 3;
    persist.byStore.plaintext = [
      ".cache/Zeal"
      ".local/share/Zeal"
    ];
    fs.".local/share/Zeal/Zeal/docsets/system".symlink.target = "/run/current-system/sw/share/docsets";
    suggestedPrograms = [ "docsets" ];
  };
}
