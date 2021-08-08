
{ pkgs, ... }: 
let
  bin = pkgs.wrapWine {
    name = "rimworld";
    is64bits = true;
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/RimWorld.v1.3.3060/RimWorldWin64.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
    wineFlags = "explorer /desktop=name,1366x768";
    tricks = ["corefonts"];
  };
in bin
