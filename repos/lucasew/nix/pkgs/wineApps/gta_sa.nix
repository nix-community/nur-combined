{pkgs, ...}:
let
  bin = pkgs.wrapWine {
    name = "gta_sa";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/GTA San Andreas/gta_sa.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/GTA San Andreas";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = [
      "d3dx9_36"
    ];
  };
in bin
