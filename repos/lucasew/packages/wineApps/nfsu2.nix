{pkgs, ...}:
let
  bin = pkgs.wrapWine {
    name = "nfsu2";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Need For Speed Underground 2/speed2.exe";
    chdir = "/run/media/lucasew/Dados/DADOS/Jogos/Need For Speed Underground 2";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = [
      "dxvk"
      "vcrun2005"
      "vcrun2008"
      "corefonts"
    ];
  };
in bin
