{ pkgs, wrapWine, fetchurl, makeDesktopItem, ... }:
let
  bin = wrapWine {
    name = "ets2";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Euro.Truck.Simulator.2.v1.28.0.10.Inclu.ALL.DLC/bin/win_x86/eurotrucks2.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
  };
  logo = fetchurl {
    url = "https://eurotrucksimulator2.com/images/logo.png";
    sha256 = "1pjb1jhzi4gsvz01gbgjb8kx5za3k83g99fjjavd4bklbxvki2wz";
  };
in
makeDesktopItem {
  name = "ets2";
  desktopName = "Euro Truck Simulator 2";
  type = "Application";
  exec = "${bin}/bin/ets2";
  icon = "${logo}";
}
