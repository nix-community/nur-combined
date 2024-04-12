{ pkgs, inputs, ... }:

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
      hash = "";
    };
  };

in
{
  programs.alacritty.package = alacritty-bin;
  home.packages = (with pkgs.nixGL.auto; [ nixGLDefault ]) ++ [ alacritty-desktop ];
}
