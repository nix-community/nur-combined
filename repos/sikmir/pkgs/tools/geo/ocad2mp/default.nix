{ stdenv, fetchsvn }:

stdenv.mkDerivation rec {
  pname = "ocad2mp";
  version = "2011-01-26";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/${pname}/code/trunk/${pname}";
    rev = "269";
    sha256 = "1700apfsjd27q9jsvvr94mk7rd0x24ib3bkn4y8hak0zvknib563";
  };

  NIX_CFLAGS_COMPILE = "-std=c++03 -include stddef.h -Wno-error=format-security";

  makeFlags = [ "-f" "Makefile.gcc" "CFG=Release" "TARGET_ARCH_BITS=64" ];

  installPhase = ''
    install -Dm755 Release/ocad2mp -t "$out/bin"
    install -Dm644 SYM.TXT $out/share/ocad2mp/sym.txt
  '';

  meta = with stdenv.lib; {
    description = "Converter from OCAD map format to Polish format";
    homepage = "https://sourceforge.net/projects/ocad2mp/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
