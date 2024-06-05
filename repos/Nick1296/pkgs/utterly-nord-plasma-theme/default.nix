{ stdenv, fetchFromGitHub, gzip, fd, coreutils, gnused, lib }:
stdenv.mkDerivation rec {
  pname = "utterly-nord-plasma-theme";
  version = "3.2";
  dontBuild = true;
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  installPhase = ''
    #position sddm theme
    mkdir -p $out/share/sddm/themes/Utterly-Nord
    cp -aR $src/sddm/* $out/share/sddm/themes/Utterly-Nord
    #make paths relative
    #${coreutils.out}/bin/chmod -R +w $out
    #${gnused.out}/bin/sed -i -- "s|/usr/share/sddm/themes/Utterly-Sweet/||g" $out/share/sddm/themes/Utterly-Sweet/Main.qml

    #position kvantum theme
    mkdir -p $out/share/Kvantum/{Utterly-Nord,Utterly-Nord-Solid,Utterly-Nord-Light,Utterly-Nord-Light-Solid}
    cp -aR $src/kvantum/* $out/share/Kvantum/Utterly-Nord
    cp -aR $src/kvantum-solid/* $out/share/Kvantum/Utterly-Nord-Solid
    cp -aR $src/kvantum-light/* $out/share/Kvantum/Utterly-Nord-Light
    cp -aR $src/kvantum-light-solid/* $out/share/Kvantum/Utterly-Nord-Light-Solid

    #position plasma theme
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord
    cp -aR $src/look-and-feel/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-solid
    cp -aR $src/look-and-feel-solid/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-solid
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-light
    cp -aR $src/look-and-feel-light/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-light
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-light-solid
    cp -aR $src/look-and-feel-light-solid/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-nord-light-solid

    # position wallpaper
    mkdir -p $out/share/wallpapers/Utterly-Nord
    cp -aR $src/wallpaper/* $out/share/wallpapers/Utterly-Nord

    #set plasma color schemes
    mkdir -p $out/share/color-schemes
    cp -aR $src/*.colors  $out/share/color-schemes

    #set Konsole color schemes
    mkdir -p $out/share/konsole
    cp -aR $src/*.colorscheme  $out/share/konsole/

    #decompress svgz assets
    #for file in $(${fd.out}/bin/fd \.svgz $out); do
    #  ${coreutils.out}/bin/chmod -R +w $(${coreutils.out}/bin/dirname $file)
    #  ${gzip.out}/bin/gunzip -S z $file
    #  done
    #make everything rdonly
    #${coreutils.out}/bin/chmod -R -w $out

  '';
  src = fetchFromGitHub {
    owner = "HimDek";
    repo = "Utterly-Nord-Plasma";
    rev = "e513b4dfeddd587a34bfdd9ba6b1d1eac8ecadf5";
    sha256 = "sha256-moLgBFR+BgoiEBzV3y/LA6JZfLHrG1weL1+h8LN9ztA=";
  };
  meta = with lib; {
    description =
      "A Slick and Modern Global theme for KDE Plasma utilizing the Nord Color Palette with transparency and blur in UI ";
    homepage = "https://himdek.com/Utterly-Nord-Plasma/";
    downloadPage = "https://github.com/HimDek/Utterly-Nord-Plasma";
    longDescription =
      "This package has most of the features working, testing might be needed for login animations and sddm theme";
    branch = "master";
    license = lib.licenses.gpl2Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
