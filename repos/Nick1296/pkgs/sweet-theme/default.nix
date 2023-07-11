{ stdenv, fetchFromGitHub, gzip, fd, coreutils, lib }:
stdenv.mkDerivation rec {
  pname = "sweet-theme";
  version = "11062023";
  dontBuild = true;
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  installPhase = ''
    #position gtk themes
    mkdir -p $out/share/{plasma/look-and-feel,themes/Sweet,sddm/themes/Sweet,icons,color-schemes}
    cp -aR $src/{cinnamon,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,xfwm4,metacity-1,assets} $out/share/themes/Sweet

    #position plasma themes
    cp -aR $src/kde/{Kvantum,aurorae,konsole} $out/share

    mkdir -p $out/share/plasma/look-and-feel/com.github.eliverlara.sweet
    cp -aR $src/kde/look-and-feel/* $out/share/plasma/look-and-feel/com.github.eliverlara.sweet


    cp -aR $src/kde/sddm/* $out/share/sddm/themes/Sweet
    cp -aR $src/kde/cursors/Sweet-cursors $out/share/icons/
    cp -aR $src/kde/colorschemes/* $out/share/color-schemes
    #get wallpapers
    mkdir -p $out/share/wallpapers
    cp -aR $src/extras/Sweet-Wallpapers $out/share/wallpapers
    #decompress svgz assets
    #for file in $(${fd.out}/bin/fd \.svgz $out); do
    #  ${coreutils.out}/bin/chmod -R +w $(${coreutils.out}/bin/dirname $file)
    #  ${gzip.out}/bin/gunzip -S z $file
    #done
    #make everything rdonly
    #${coreutils.out}/bin/chmod -R -w $out
  '';
  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "c4a4c0ce8a67569fe6440b876fc667ead14b49ce";
    sha256 = "sha256-KLfTwL2dZa9tcmSTbnOwtP7uMpDnyNcFoMCxcSoLU6E=";
  };
  meta = with lib; {
    description = "Light and dark colorful Gtk3.20+ theme";
    homepage = "www.gnome-look.org/p/1253385/";
    downloadPage = "https://github.com/EliverLara/Sweet";
    longDescription = "This package uses the Nova branch, that includes Qt and sddm themes";
    branch = "nova";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
