{pkgs, ...}: pkgs.makeDesktopItem {
  name = "amongUs";
  desktopName = "Among Us";
  type = "Application";
  exec = ''${pkgs.wineFull}/bin/wine "/run/media/lucasew/Dados/DADOS/Jogos/Among_Us/Among Us.exe"'';
  icon = builtins.fetchurl {
    url = "https://img.utdstc.com/icons/among-us-android.png";
    sha256 = "1918sd17jpbk7xipwx891mrrf5ws5hbhbgp2zizkyi26fmkc23j6";
  };
}
