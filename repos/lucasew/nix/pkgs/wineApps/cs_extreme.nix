{pkgs, ...}:
let
  bin = pkgs.wrapWine {
    name = "cs_extreme";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Counter-Strike Xtreme V6/Counter Strike Xtreme.exe";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/Counter-Strike Xtreme V6";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = [
      "comctl32ocx"
      "vb6run"
    ];
  };
in bin
