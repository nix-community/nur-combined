{ stdenv, fetchurl, lib, psutils, dialog, texlive, makeWrapper, automake, autoconf, imagemagick, ghostscript, perl, perlPackages }:
stdenv.mkDerivation rec {
  name = "muttprint-${version}";
  version = "0.73";
  src = fetchurl {
    url = "http://downloads.sf.net/muttprint/${name}.tar.gz";
    sha256 = "1dny4niyibfgazwlzfcnb37jy6k140rs6baaj629z12rmahfdavw";
  };
  patches = [
    ./0.73-4.diff.gz
    ./regex.patch
    ./two_edge.patch
    ];
  preConfigure = ''
    aclocal
    automake --add-missing --copy
    autoconf
    '';
  preBuild = ''
    cd pics
    convert -flop BabyTuX.eps BabyTuX.eps
    for i in BabyTuX_color.eps BabyTuX.eps Debian_color.eps \
        Debian.eps Gentoo.eps Gentoo_color.eps ; do
      convert $i $(basename $i .eps).png
    done
    convert penguin.eps penguin.jpg
    cd ..
    '';
  postInstall = ''
    perlFlags=
    for i in $(IFS=:; echo $PERL5LIB); do
        perlFlags="$perlFlags -I$i"
    done

    sed -i "$out/bin/muttprint" -e "s|^#\!\(.*[ /]perl.*\)$|#\!\1$perlFlags|"
    sed -i "$out/bin/muttprint" -e "s|ENV{HOME}/.muttprintrc|ENV{XDG_CONFIG_HOME}/muttprint/muttprintrc|"

    wrapProgram $out/bin/muttprint \
      --prefix PATH : ${lib.makeBinPath [ psutils dialog
      (texlive.combine { inherit (texlive) scheme-basic utopia fancyvrb lastpage marvosym ucs cm-super; }) ]}
    '';
  buildInputs = [ makeWrapper automake autoconf imagemagick ghostscript perl ] ++
    (with perlPackages; [ TimeDate FileWhich TextIconv ]);
}
