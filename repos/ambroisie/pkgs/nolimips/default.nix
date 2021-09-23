{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "nolimips";
  version = "0.11";

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-OjbfcBwCZtFP0usz8YXA0lN8xs0jS4I19mkh9p7VHc8=";
  };

  doCheck = true;

  meta = with lib; {
    description = "A basic MIPS architecture simulator";
    longDescription = ''
      A basic MIPS architecture simulator, which implements a few system calls
      and supports  an arbitrary number of registers.
    '';
    homepage = "https://www.lrde.epita.fr/wiki/Nolimips";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ ambroisie ];
  };
}
