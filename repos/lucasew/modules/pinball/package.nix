{pkgs, ...}:
# FIXME: Can't hear that lovely music and the sound effects
let
  pinball = pkgs.stdenv.mkDerivation rec {
    name = "mspinball";
    version = "1.0";
    src = pkgs.fetchurl {
      url = "https://archive.org/download/SpaceCadet_Plus95/Space_Cadet.rar";
      sha256 = "3cc5dfd914c2ac41b03f006c7ccbb59d6f9e4c32ecfd1906e718c8e47f130f4a";
    };
    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];
    unpackPhase = ''
      mkdir -p $out/share/mspinball
      cd $out/share/mspinball && ${pkgs.unrar}/bin/unrar x ${src}
    '';
    installPhase = ''
      makeWrapper ${pkgs.wineWowPackages.stable}/bin/wine $out/bin/pinball \
      --add-flags "$out/share/mspinball/PINBALL.exe" \
      # sed -i 's/WaveOutDevice=0/WaveOutDevice=1/' $out/share/mspinball/WAVEMIX.INF
    '';
  };
in pkgs.makeDesktopItem {
  name = "Pinball";
  desktopName = "Pinbal - Space Cadet";
  icon = builtins.fetchurl {
    url = "https://www.chip.de/ii/1/8/8/0/2/9/2/3/028c4582789e6c07.jpg";
    sha256 = "1lwsnsp4hxwqwprjidgmxksaz13ib98w34r6nxkhcip1z0bk1ilz";
  };
  type = "Application";
  exec = "${pinball}/bin/pinball";
}
