{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let version = "2.015";
in stdenv.mkDerivation rec {
  name = "minionpro-${version}";

  src = fetchzip {
    name = "scripts";
    stripRoot = false;
    url = "http://mirrors.ctan.org/fonts/minionpro/scripts.zip";
    sha256 = "0w5i6r5chf2c2mp3pd8b7as3nl0ri3f43cavxiix0wcv1da1y0lw";
  };
  enc = fetchurl {
    name = "enc";
    url = "http://mirrors.ctan.org/fonts/minionpro/enc-2.000.zip";
    sha256 = "12mwn0409pf7qcigp7alvrwnz8j1zpiv10ihw8jbffdpc97gdfaj";
  };
  metrics = fetchurl {
    name = "metrics";
    url = "http://mirrors.ctan.org/fonts/minionpro/metrics-base.zip";
    sha256 = "0571jv8i5x0aii6ycm70hwlsfm1swb077vmzdby5qvc3c5vjyhvr";
  };
  adobereader = fetchurl {
    url = "http://ardownload.adobe.com/pub/adobe/reader/unix/8.x/8.1.3/deu/AdobeReader_deu-8.1.3-1.i486.tar.bz2";
    sha256 = "1r4hvrb5vniwpdgccn3j4729kndmdgps285jkkm88vk718kpsv41";
  };
  myriadpdf = fetchurl {
    name = "MyriadProAR7.pdf";
    url = "https://github.com/henrikgit/MPro-Installation-Guide-GitHub/raw/fae4e4c5baad008128b3b513f84d86d32b8b9253/MyriadPro-stuff/MyriadProAR7-manual-thingy.pdf";
    sha256 = "0x7cmfd9kai2kwq4zqkhashrnazcwqs8rk6i5m3xcazcs02l4iq8";
  };
  myriadzip = fetchurl {
    name = "MyriadProAR7.zip";
    url = "https://github.com/henrikgit/MPro-Installation-Guide-GitHub/raw/fae4e4c5baad008128b3b513f84d86d32b8b9253/MyriadPro-stuff/MyriadProAR7.zip";
    sha256 = "0pjfm3hsl1a41v9rms8li57q1n2w9yp7g4rn4m8h4n30sig57y6z";
  };
  srcs = [ adobereader src ];

  passthru = { tlType = "run"; pname = "minionpro"; inherit version; };
  
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
 			       
  nativeBuildInputs = [ texlive.combined.scheme-minimal libarchive lcdf-typetools ];

  sourceRoot = ".";
  buildPhase = (''
   (cd AdobeReader; tar xf COMMON.TAR; mv Adobe/Reader8/Resource/Font/M*.otf ../scripts/otf)
   (cd scripts; ./convert.sh)
   mkdir myriad;
   bsdtar -C myriad -xf ${myriadzip}
   cd myriad
   [ -d fonts/tfm/adobe ] && rm -r fonts/tfm/adobe
   mv fonts/tfm/Adobe fonts/tfm/adobe
   
   [ -d fonts/type1/adobe ] && rm -r fonts/type1/adobe
   mv fonts/type1/Adobe fonts/type1/adobe
   
   mkdir -p fonts/map/dvips/MyriadPro
   mv dvips/MyriadPro/MyriadPro.map fonts/map/dvips/MyriadPro
   sed -i -e 's/\r$//' fonts/map/dvips/MyriadPro/MyriadPro.map
   
   [ -d fonts/enc ] || mkdir fonts/enc
   mv dvips fonts/enc/
   
   cd ..
 '');

  installPhase = ''
    TEXMFDIST=""
#    TEXMFDIST="texmf-dist"
    install -d $out/$TEXMFDIST/fonts/type1/adobe/MinionPro
    install -d $out/$TEXMFDIST/fonts/type1/adobe/MyriadPro
    cp scripts/pfb/Min*.pfb \
        $out/$TEXMFDIST/fonts/type1/adobe/MinionPro
    cp scripts/pfb/Myr*.pfb \
        $out/$TEXMFDIST/fonts/type1/adobe/MyriadPro
    bsdtar -C $out/$TEXMFDIST -xf ${enc}
    bsdtar -C $out/$TEXMFDIST -xf ${metrics}
    cp -R myriad/* $out/$TEXMFDIST
    sed -i -e 's+\[++' $out/$TEXMFDIST/fonts/map/dvips/MinionPro/MinionPro.map
    sed -i -e 's+\[++' $out/$TEXMFDIST/fonts/map/dvips/MyriadPro/MyriadPro.map
    install -Dm644 ${myriadpdf} \
      $out/$TEXMFDIST/doc/latex/MyriadPro/MyriadPro.pdf
    chmod o+r $out/$TEXMFDIST/doc/latex/MinionPro/tabfigures.pdf \
              $out/$TEXMFDIST/doc/latex/MinionPro/fontaxes.pdf \
              $out/$TEXMFDIST/doc/latex/MinionPro/otfontdef.pdf
	      
#    install -d $out/$TEXMFDIST/web2c/
#    echo -e "Map MinionPro.map\nMap MyriadPro.map\n" > $out/$TEXMFDIST/web2c/updmap.cfg
    
    #mkdir -p $out/share
    #ln -s $out/texmf* $out/share
    #mktexlsr $out/texmf*
'';

  meta = with lib; {
    description = "Myriad and Minion for LaTeX (the not-xeLaTeX way)";
    homepage = https://ctan.org/tex-archive/fonts/minionpro/;
    license = licenses.unfree;
  };
}
