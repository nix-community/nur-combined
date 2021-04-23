{ lib, stdenv, fetchFromSourcehut, mailcap, openssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmnisrv";
  version = "2021-03-23";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "8b65e303b01fc573cb1c40a365fb5db166146a37";
    hash = "sha256-H+niIRCetKe2wwoC5pKpcYOd6z+DmHhy2LWN9syPEdg=";
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
    platforms = platforms.unix;
  };
}
