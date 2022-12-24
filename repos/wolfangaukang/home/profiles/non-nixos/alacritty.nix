{ pkgs, ... }:

let
  alacritty-bin = pkgs.writeScriptBin "alacritty" ''
    #!${pkgs.stdenv.shell}
    exec ${pkgs.nixGL.auto.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty
  '';

  alacritty-desktop = pkgs.makeDesktopItem rec {
    type = "Application";
    name = "Alacritty";
    desktopName = "Alacritty";
    exec = "${alacritty-bin}/bin/alacritty %U";
    genericName = "Terminal";
    icon = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg";
      sha256 = "1ljxxdljj76a3vqldzssjg5j45ljazk7ismci4cd5ikyvb89m3b5";
    };
  };
in {
  imports = [
    ./nixgl.nix
    ../common/alacritty.nix
  ];

  programs.alacritty.package = alacritty-bin;
  home.packages = [ alacritty-desktop ];
}
