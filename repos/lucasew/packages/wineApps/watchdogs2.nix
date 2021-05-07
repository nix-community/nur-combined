{ pkgs, ... }: 
# FIXME: buggy graphics. Other DirectX implementations are glitching and the stock one have buggy colors.
let
  bin = pkgs.wrapWine {
    name = "watchdogs2";
    is64bits = true;
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Watch Dogs 2/bin/WatchDogs2.exe";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/Watch Dogs 2/bin/";
    tricks = [
    ];
  };
in bin
