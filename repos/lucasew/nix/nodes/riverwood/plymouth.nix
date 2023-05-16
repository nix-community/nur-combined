{config, pkgs, lib, ...}: {
  boot.plymouth = {
    enable = true;
    theme = "breeze"; # TODO: trocar a engrenagem girando por algo menos tosco
    logo = pkgs.stdenv.mkDerivation {
      name = "out.png";
      dontUnpack = true;
      src = pkgs.fetchurl {
        url = "https://static.wikia.nocookie.net/elderscrolls/images/7/74/SettlementWhite.svg";
        sha256 = "00k9gm34i05rjia1ljglv7x3kp3a0q3kfv88dh8lar7hilq0w6l1";
      };
      nativeBuildInputs = with pkgs; [
        inkscape
      ];
      buildPhase = ''
        inkscape --export-type="png" $src -o wallpaper.png -w 150 -h 210 -o wallpaper.png
      '';
      installPhase = ''
        install -Dm0644 wallpaper.png $out
      '';
    };
  };
}
