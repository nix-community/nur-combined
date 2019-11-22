{ stdenv, fetchurl
}:

stdenv.mkDerivation rec {
  version = "1.1.4";
  name = "dcw-gmt-${version}";

  src = fetchurl {
    url = "http://www.scc.u-tokai.ac.jp/gmt/${name}.tar.gz";
    sha256 = "1lxa8fj5w0ya24vcinjf6bdagbjf5q1csr8kf47lmxfpphm40iwd";
  };
  
  
  installPhase=''
    tar xvf ${src}
    mkdir -p $out
    mv * $out
    '';
  
  meta = {
    description     =  "Digital Chart of the World (DCW) for GMT";
    longDescription = '' 
      DCW-GMT is an enhancement to the original 1:1,000,000 scale vector basemap 
      of the world available from the Princeton University Digital Map and 
      Geospatial Information Center and from GeoCommunity at 
      http://data.geocomm.com/readme/dcw/dcw.html. 
      This data is for use by GMT, the Generic Mapping Tools.
      '';
    homepage        =   http://www.soest.hawaii.edu/pwessel/dcw/index.html;
    # License: LGPL-3+
    license         = with stdenv.lib.licenses; [ lgpl3Plus ];
    maintainers     = [ stdenv.lib.maintainers.ltavard ];
    platforms       = stdenv.lib.platforms.linux;
  };
}

