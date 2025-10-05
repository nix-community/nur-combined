{
  stdenv,
  lib,
  fetchsvn,
  cmake,
  nasm,
  libX11,
}:

stdenv.mkDerivation {
  pname = "linrad";
  version = "2024-04-26";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/linrad/code/trunk";
    rev = "1027";
    sha256 = "sha256-zOGpLX5OTSFhbme6hENN+Z1gwcxkHoeDDDg6LZQvcM0=";
  };

  nativeBuildInputs = [
    cmake
    nasm
  ];

  buildInputs = [ libX11 ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";

  installPhase = ''
    install -Dm755 clinrad -t $out/bin
  '';

  meta = {
    description = "Software defined radio receiver for x11";
    homepage = "http://www.sm5bsz.com/linuxdsp/linrad.htm";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
