{ stdenv, fetchurl
}:

stdenv.mkDerivation rec {
  version = "2.3.7";
  name = "gshhg-gmt-${version}";

  src = fetchurl {
    url = "http://www.scc.u-tokai.ac.jp/gmt/${name}.tar.gz";
    sha256 = "0zzy5jlw4hmh13gpbwc1rq05llwpaxi2x17g7c48qwd0zibakccv";
  };
  
  installPhase=''
    tar xvf ${src}
    mkdir -p $out
    mv * $out
    '';
  
  meta = {
    description     =  "Global Self-consistent Hierarchical High-resolution Geography (GSHHG)";
    longDescription = '' 
      GSHHG is a high-resolution shoreline data set amalgamated from two databases: 
      Global Self-consistent Hierarchical High-resolution Shorelines (GSHHS) and 
      CIA World Data Bank II (WDBII). 
      GSHHG contains vector descriptions at five different resolutions of land 
      outlines, lakes, rivers, and political boundaries. 
      This data is for use by GMT, the Generic Mapping Tools.
      '';
    homepage        =   http://www.soest.hawaii.edu/pwessel/gshhg/index.html;
    # License: LGPL-3+
    license         = with stdenv.lib.licenses; [ lgpl3Plus ];
    maintainers     = [ stdenv.lib.maintainers.ltavard ];
    platforms       = stdenv.lib.platforms.linux;
  };
}

