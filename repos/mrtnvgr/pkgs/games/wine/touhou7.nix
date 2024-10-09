{ fetchzip, wrapWine, ... }: 
let 
  src = fetchzip {
    url = "https://archive.org/download/touhou-7-perfect-cherry-blossom/Touhou%207%20-%20Perfect%20Cherry%20Blossom%20(English).zip";
    hash = "";
  };

  pkg = wrapWine {
    name = "touhou7";
    executable = "$WINEPREFIX/drive_c/touhou7/th07e.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ln -s ${src} touhou7
      popd
    '';
  };
in pkg
