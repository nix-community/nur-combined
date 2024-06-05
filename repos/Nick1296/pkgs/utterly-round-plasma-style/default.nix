{ stdenv, fetchFromGitHub, coreutils, gzip, fd, lib }:
stdenv.mkDerivation rec {
  pname = "utterly-round-plasma-style";
  version = "2.1";
  dontBuild = true;
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  installPhase = ''
    #position aurorae theme
    mkdir -p $out/share/aurorae/themes/{Utterly-Round-Dark,Utterly-Round-Dark-Solid}
    mkdir -p $out/share/aurorae/themes/{Utterly-Round-Light,Utterly-Round-Light-Solid}
    cp -aR $src/aurorae/light/solid/* $out/share/aurorae/themes/Utterly-Round-Light-Solid
    cp -aR $src/aurorae/light/translucent/* $out/share/aurorae/themes/Utterly-Round-Light
    cp -aR $src/aurorae/dark/solid/* $out/share/aurorae/themes/Utterly-Round-Dark-Solid
    cp -aR $src/aurorae/dark/translucent/* $out/share/aurorae/themes/Utterly-Round-Dark

    #postion desktop theme
    mkdir -p $out/share/plasma/desktoptheme/{Utterly-Round-Solid,Utterly-Round}
    cp -aR $src/desktoptheme/solid/* $out/share/plasma/desktoptheme/Utterly-Round-Solid
    cp -aR $src/desktoptheme/translucent/* $out/share/plasma/desktoptheme/Utterly-Round

    #decompress svgz assets (uneeded)
    #for file in $(${fd.out}/bin/fd \.svgz $out); do
    #  #icons folder has some svgz which are not compressed
    #  ${coreutils.out}/bin/chmod -R +w $(${coreutils.out}/bin/dirname $file)
    #  if ! ${gzip.out}/bin/gunzip -S z -f $file; then
    #    ${coreutils.out}/bin/mv $file ''${file::-1}
    #  fi
    #  done
    #make everything rdonly
    #${coreutils.out}/bin/chmod -R -w $out
  '';
  src = fetchFromGitHub {
    owner = "HimDek";
    repo = "Utterly-Round-Plasma-Style";
    rev = "6280f69781b7fa9613b7a9c502d8d61e11fefca5";
    sha256 = "sha256-mlqRMz0cAZnnM4xE6p7fMzhGlqCQcM4FxmDlVnbGUgQ=";
  };
  meta = with lib; {
    description =
      "A Desktop Theme for KDE Plasma that follows all color scheme ";
    homepage = "https://himdek.com/Utterly-Round-Plasma-Style/";
    downloadPage = "https://github.com/HimDek/Utterly-Round-Plasma-Style";
    branch = "master";
    license = lib.licenses.gpl2Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
