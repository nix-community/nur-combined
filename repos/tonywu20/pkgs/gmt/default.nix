{ stdenv, fetchurl, cmake, ghostscript, netcdf, gdal, pcre, zlib, curl, fftwFloat,
graphicsmagick, gshhg-gmt, dcw-gmt
}:

stdenv.mkDerivation rec {
  version = "5.4.5"; 
  name = "gmt-${version}";

  src = fetchurl {
    url = "http://www.scc.u-tokai.ac.jp/gmt/${name}-src.tar.gz";
    sha256 = "1xlyydmqkhpplkf8plhy7vw47qj3v954qf0skxgls84yhv3jjmi2";
  };

  propagatedBuildInputs = [ netcdf gdal pcre zlib curl gshhg-gmt graphicsmagick ];
  buildInputs = [ cmake fftwFloat ];
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_C_FLAGS=-fstrict-aliasing"
    "-DDCW_ROOT=${dcw-gmt}"
    "-DGSHHG_ROOT=${gshhg-gmt}"
    "-DNETCDF_ROOT=${netcdf}"
    "-DGDAL_ROOT=${gdal}"
    "-DPCRE_ROOT=${pcre}"
    "-DCMAKE_VERBOSE_MAKEFILE=ON"
    "-DGMT_INSTALL_MODULE_LINKS=OFF"
    "-DGMT_INSTALL_TRADITIONAL_FOLDERNAMES=OFF"
    "-DLICENSE_RESTRICTED=LGPL" # or -DLICENSE_RESTRICTED=no to include non-free code
    "-DFFTW3_ROOT=${fftwFloat}"];
  
  enableParallelBuilding = true;

  meta = {
    description     =  "The Generic Mapping Tools";
    longDescription = '' 
      and Cartesian data sets and producing PostScript illustrations ranging from 
      simple x-y plots via contour maps to artificially illuminated surfaces and 
      3D perspective views.
      '';
    homepage        = http://gmt.soest.hawaii.edu/;
    # License: GPL-3+, LGPL-3+, or Restrictive depending on LICENSE_RESTRICTED setting
    license         = with stdenv.lib.licenses; [ lgpl3Plus gpl3Plus ];
    maintainers     = [ stdenv.lib.maintainers.ltavard ];
    platforms       = stdenv.lib.platforms.linux;
  };
}

