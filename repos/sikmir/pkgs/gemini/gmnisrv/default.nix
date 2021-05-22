{ lib, stdenv, fetchFromSourcehut, mailcap, openssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmnisrv";
  version = "2021-05-16";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "b9a92193e96bbe621ebc8430d8308d45a5b86cef";
    hash = "sha256-eMKsoq3Y+eS20nxI7EoDLbdwdoB6shbGt6p8wS+uoPc=";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ openssl ];

  configureFlags = [
    "--with-mimedb=${mailcap}/etc/mime.types"
  ];

  meta = with lib; {
    description = "Simple Gemini protocol server";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
