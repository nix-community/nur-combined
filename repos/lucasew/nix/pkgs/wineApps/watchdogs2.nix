{ pkgs, ... }: 
# FIXME: buggy graphics. Other DirectX implementations are glitching and the stock one have buggy colors.
let
  bin = pkgs.wrapWine {
    name = "watchdogs2";
    is64bits = true;
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Watch Dogs 2/bin/WatchDogs2.exe";
    wineFlags = "explorer /desktop=name,1366x768";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/Watch Dogs 2/bin/";
    tricks = [
      "corefonts"
      "d3dx11_43"
    ];
  };
in bin
