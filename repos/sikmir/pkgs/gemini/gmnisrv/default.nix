{ lib, stdenv, fetchFromSourcehut, mailcap, openssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmnisrv";
  version = "2021-03-23";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "8b65e303b01fc573cb1c40a365fb5db166146a37";
    sha256 = "1n0iiz6gd3dmv1r7i6437zmrv0vim69fc0haqfvagd4y20hy5s8z";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ openssl ];

  configureFlags = [
    "--with-mimedb=${mailcap}/etc/mime.types"
  ];

  meta = with lib; {
    description = "Simple Gemini protocol server";
    homepage = "https://git.sr.ht/~sircmpwn/gmnisrv";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
