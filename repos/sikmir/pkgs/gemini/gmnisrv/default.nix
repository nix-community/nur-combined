{ stdenv, fetchgit, openssl, pkg-config, scdoc }:

stdenv.mkDerivation {
  pname = "gmnisrv";
  version = "2020-12-27";

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/gmnisrv";
    rev = "fbef1d34a1abd2614f85afee415fe0f417038efe";
    sha256 = "0y42vj5vy8pk732dkbdywgixr9bxpg11hf4w2qsa1vwqw3xbvdka";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ openssl ];

  meta = with stdenv.lib; {
    description = "Simple Gemini protocol server";
    homepage = "https://git.sr.ht/~sircmpwn/gmnisrv";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
