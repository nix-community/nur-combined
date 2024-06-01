{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec{
  version = "1.3.0";
  pname = "ps2client";

  src = fetchFromGitHub {
    owner = "ps2dev";
    repo  = "ps2client";
    rev = "v${version}";
    sha256 = "sha256-XGfwISmiwXl1EDgQJK+rA9kZDLetAUp76F7jIbvE9ec=";
  };

  patchPhase = ''
   sed -i -e "s|-I/usr/include||g" -e "s|-I/usr/local/include||g" Makefile
  '';

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = with lib; {
    description = "Desktop clients to interact with ps2link and ps2netfs";
    homepage = "https://github.com/ps2dev/ps2client";
    license = licenses.bsd3;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.unix;
  };
}
