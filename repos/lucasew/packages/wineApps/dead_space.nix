{pkgs, ...}:
let
  bin = pkgs.wrapWine {
    name = "dead_space";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Dead Space/Dead Space.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/Dead Space";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = [
      "d3dx9_36"
    ];
  };
in bin
