{ lib, stdenv, fetchsvn }:

stdenv.mkDerivation {
  pname = "ocad2mp";
  version = "2011-01-26";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/ocad2mp/code/trunk/ocad2mp";
    rev = "269";
    sha256 = "sha256-w5QV7dwfTAWRJ3ausSIRHbR8ZiUp761lwkc0qd1VAJw=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile.gcc \
      --replace "CXX=g++" "" \
      --replace "LINK=g++" "LINK=$CXX" \
      --replace "-lgcc" ""
  '';

  NIX_CFLAGS_COMPILE = [
    "-std=c++03"
    "-include stddef.h"
  ];

  makeFlags = [
    "-f Makefile.gcc"
    "CFG=Release"
    "TARGET_ARCH_BITS=64"
  ];

  hardeningDisable = [ "format" ];

  installPhase = ''
    install -Dm755 Release/ocad2mp -t $out/bin
    install -Dm644 SYM.TXT $out/share/ocad2mp/sym.txt
  '';

  meta = with lib; {
    description = "Converter from OCAD map format to Polish format";
    homepage = "https://sourceforge.net/projects/ocad2mp/";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
