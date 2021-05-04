{ lib, stdenv, fetchFromSourcehut, mailcap, openssl, pkg-config, scdoc }:

stdenv.mkDerivation rec {
  pname = "gmnisrv";
  version = "2021-05-04";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "0dc0e4432a70eafde69509fde8a29802e46ae712";
    hash = "sha256-PvDU5QppUpkDtfk8IsD/Bo2SzS+4Igee3cGat+7Y0iM=";
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
