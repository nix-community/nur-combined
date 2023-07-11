{ stdenv, fetchFromGitHub, gzip, fd, coreutils, gnused, lib }:
stdenv.mkDerivation rec {
  pname = "utterly-sweet-plasma-theme";
  version = "2.1";
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
    cp -aR $src/UtterlySweet.colors  $out/share/color-schemes

    #set Konsole color schemes
    mkdir -p $out/share/konsole
    cp -aR $src/Utterly-Sweet-Konsole.colorscheme  $out/share/konsole/Utterly-Sweet.colorscheme
    cp -aR $src/Utterly-Sweet-Solid-Konsole.colorscheme  $out/share/konsole/Utterly-Sweet-Solid.colorscheme

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
    rev = "4bb007e865d559de8dd43bbffb93778ea136f957";
    sha256 = "sha256-oEyf6FI5XSjXPZjzBiGypwZY89ulhwAwk9QIJ3pMw/M=";
  };
  meta = with lib; {
    description = "A Dark Bluish and Blurry Global theme for Plasma 5";
    homepage = "https://himdek.com/Utterly-Sweet-Plasma/";
    downloadPage = "https://github.com/HimDek/Utterly-Sweet-Plasma";
    longDescription = "This package has most of the feature working, testing might be needed for login animations and sddm theme";
    branch = "master";
    license = lib.licenses.gpl2Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
