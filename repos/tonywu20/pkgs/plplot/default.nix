{ stdenv, fetchurl, perl , python , cmake }: 


stdenv.mkDerivation rec {
	version="5.13.0";
	name="plplot";
	nativeBuildInputs = [cmake ];
	buildInputs = [ python perl ];
	src = fetchurl {
		url ="https://sourceforge.net/projects/plplot/files/plplot/${version}%20Source/${name}-${version}.tar.gz";
		sha256="ec36bbee8b03d9d1c98f8fd88f7dc3415560e559b53eb1aa991c2dcf61b25d2b";
	};
	enableParallelBuilding =true;
	cmakeFlags= ["-DCMAKE_SKIP_BUILD_RPATH=false" ];
	postConfigurePhase = ''
		patchelf --set-rpath $out/lib/qsastime:$out/lib:$out/lib/csa"
	'';
	meta = {
        	description = "PLplot is a cross-platform software package for creating scientific plots";
        	homepage = "http://plplot.sourceforge.net/";
        	license = stdenv.lib.licenses.lgpl2;
        	platforms = stdenv.lib.platforms.all;
     };
}
