{ pkgs, fetchurl, ... }: 
let
  bin = pkgs.wrapWine {
    name = "among_us";
    executable = "/run/media/lucasew/Dados/DADOS/Jogos/Among_Us/Among Us.exe";
    home = "/run/media/lucasew/Dados/DADOS/Lucas/";
  };
in pkgs.makeDesktopItem {
  name = "amongUs";
  desktopName = "Among Us";
  type = "Application";
  exec = ''${bin}/bin/among_us'';
  icon = fetchurl {
    # icon from playstore
    name = "amongus.png";
    url = "https://play-lh.googleusercontent.com/VHB9bVB8cTcnqwnu0nJqKYbiutRclnbGxTpwnayKB4vMxZj8pk1220Rg-6oQ68DwAkqO=s180";
    sha256 = "0knyfxbmnw0ad68zv9h5rmh6102lnn81silzkqi1rpixzc2dgp6b";
  };
}
