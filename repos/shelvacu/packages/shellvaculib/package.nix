{ lib, runCommandLocal }:
let
  fileDrv = builtins.path {
    name = "shellvaculib.bash";
    path = ./shellvaculib.bash;
  };
in
runCommandLocal "shellvaculib"
  {
    passthru.file = fileDrv;

    meta = {
      description = "Bunch of misc shell functions I find useful";
      license = [ lib.licenses.mit ];
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      mainProgram = null;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p "$out"/share
    mkdir -p "$out"/bin
    ln -s ${fileDrv} "$out"/share/shellvaculib.bash
    ln -s ${fileDrv} "$out"/bin/shellvaculib.bash
  ''
