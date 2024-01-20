{ stdenv, lib, fetchsvn, cmake, nasm, libX11 }:

stdenv.mkDerivation {
  pname = "linrad";
  version = "2023-11-12";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/linrad/code/trunk";
    rev = "1024";
    sha256 = "sha256-SiP/uckq+Ph888w+4z0hsUl2N/UYbMtoYbLcbeJ7ja8=";
  };

  nativeBuildInputs = [ cmake nasm ];

  buildInputs = [ libX11 ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";

  installPhase = ''
    install -Dm755 clinrad -t $out/bin
  '';

  meta = with lib; {
    description = "Software defined radio receiver for x11";
    homepage = "http://www.sm5bsz.com/linuxdsp/linrad.htm";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
