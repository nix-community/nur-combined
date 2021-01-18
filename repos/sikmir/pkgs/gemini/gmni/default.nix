{ stdenv, fetchgit, openssl, pkg-config, scdoc }:

stdenv.mkDerivation {
  pname = "gmni";
  version = "2021-01-07";

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/gmni";
    rev = "4fbc632b22172daa976d8e1c9a2db75d52ee3232";
    sha256 = "1jasamkjy90b169hwl8p78ns92fs5vlpzr50pxcfsfgny8628sin";
  };

  nativeBuildInputs = [ pkg-config scdoc ];

  buildInputs = [ openssl ];

  meta = with stdenv.lib; {
    description = "Gemini client";
    homepage = "https://git.sr.ht/~sircmpwn/gmni";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
