{pkgs, ...}:
let
  bin = pkgs.wrapWine {
    name = "flatout2";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/FlatOut 2/FlatOut2.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/FlatOut 2";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = [
      "d3dx9"
    ];
  };
in bin
