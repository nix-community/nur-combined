{ lib, stdenv, libgit2, fetchgit }:

stdenv.mkDerivation rec {
  pname = "stagit-gemini";
  version = "2022-07-08";

  src = fetchgit {
    url = "https://git.milotier.net/stagit-gemini";
    rev = "eddfa077851ffcdbdf377f7920fb481025f7ba31";
    hash = "sha256-U97Ex0OtR8eXvd6vK3rbrGlK7moEvBnVWUTwPyMUgPI=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ libgit2 ];

  meta = with lib; {
    description = "A fork of stagit-gopher that generates gemtext";
    homepage = "https://git.milotier.net/git/stagit-gemini/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
