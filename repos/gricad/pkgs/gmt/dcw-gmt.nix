{ stdenv, fetchurl
}:

stdenv.mkDerivation rec {
  version = "1.1.2";
  name = "dcw-gmt-${version}";

  src = fetchurl {
    url = "http://www.soest.hawaii.edu/pwessel/dcw/${name}.tar.gz";
    sha256 = "1dmz1001mawlkymcs1gdhdsfyf3zphalqb8qnl87nzk5im7ha6gp";
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

