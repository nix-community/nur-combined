{ stdenv, fetchFromGitHub, gzip, fd, coreutils, gnused, lib }:
stdenv.mkDerivation rec {
  pname = "utterly-sweet-plasma-theme";
  version = "3.2";
  dontBuild = true;
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  installPhase = ''
    #position sddm theme
    mkdir -p $out/share/sddm/themes/Utterly-Sweet
    cp -aR $src/sddm/* $out/share/sddm/themes/Utterly-Sweet
    #make paths relative
    #${coreutils.out}/bin/chmod -R +w $out
    #${gnused.out}/bin/sed -i -- "s|/usr/share/sddm/themes/Utterly-Sweet/||g" $out/share/sddm/themes/Utterly-Sweet/Main.qml

    #position kvantum theme
    mkdir -p $out/share/Kvantum/{Utterly-Sweet,Utterly-Sweet-Solid}
    cp -aR $src/kvantum/* $out/share/Kvantum/Utterly-Sweet
    cp -aR $src/kvantum-solid/* $out/share/Kvantum/Utterly-Sweet-Solid

    #position plasma theme
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-sweet
    cp -aR $src/look-and-feel/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-sweet
    mkdir -p $out/share/plasma/look-and-feel/com.github.himdek.utterly-sweet-solid
    cp -aR $src/look-and-feel-solid/* $out/share/plasma/look-and-feel/com.github.himdek.utterly-sweet-solid

    # position wallpaper
    mkdir -p $out/share/wallpapers/Utterly-Sweet
    cp -aR $src/wallpaper/* $out/share/wallpapers/Utterly-Sweet

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
    repo = "Utterly-Sweet-Plasma";
    rev = "0e41585af1848760e3e18254b4d357cdf65a7206";
    sha256 = "sha256-BbJTforvMcBverBhFPen/wdhlbh7FNhOU9QbIpz8MBc=";
  };
  meta = with lib; {
    description =
      "A Slick and Modern Global theme for KDE Plasma utilizing the Sweet Color Palette with transparency and blur in UI ";
    homepage = "https://himdek.com/Utterly-Sweet-Plasma/";
    downloadPage = "https://github.com/HimDek/Utterly-Sweet-Plasma";
    longDescription =
      "This package has most of the feature working, testing might be needed for login animations and sddm theme";
    branch = "master";
    license = lib.licenses.gpl2Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
