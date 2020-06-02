{ lib
, stdenv
, fetchurl
}:

let
  pname = "dietlibc";
  version = "0.34";
  sha256 = "1kis7cwi9aqp0j1vjzkd14pjfnrm0cziznlm5vd4c16hcddav53r";
in

stdenv.mkDerivation  {
  inherit pname;
  inherit version;

  src = fetchurl {
    url = "https://www.fefe.de/dietlibc/dietlibc-${version}.tar.xz";
    inherit sha256;
  };

  patchPhase = ''
      substituteInPlace ./Makefile --replace "/opt/diet" "$out"
      substituteInPlace ./libdl/Makefile --replace "/opt/diet" "$out"
      substituteInPlace ./contrib/Makefile.dyn --replace "/opt/diet" "$out"
  '';

  enableParallelBuilding=true;

  installPhase = ''
    make install
  '';

  meta = with lib; {
    homepage = "https://www.fefe.de/dietlibc/";
    description = "a libc optimized for small size";
    license = [ licenses.gpl2 ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux;
  };
}
