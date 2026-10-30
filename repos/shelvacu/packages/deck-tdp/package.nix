{
  writers,
  python3Packages,
  makeDesktopItem,
  symlinkJoin,
}:
let
  bin = writers.writePython3Bin "deck-tdp" {
    libraries = [ python3Packages.tkinter ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./main.py);
in
symlinkJoin {
  name = "deck-tdp";
  paths = [
    bin
    (makeDesktopItem {
      name = "deck-tdp";
      desktopName = "TDP Limits";
      exec = "deck-tdp";
      icon = "battery";
      categories = [ "System" ];
    })
  ];
}
